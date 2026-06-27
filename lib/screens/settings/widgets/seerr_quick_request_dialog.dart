import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:fladder/providers/seerr_api_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/screens/settings/settings_list_tile.dart';
import 'package:fladder/screens/shared/adaptive_dialog.dart';
import 'package:fladder/seerr/seerr_models.dart';
import 'package:fladder/util/localization_helper.dart';
import 'package:fladder/widgets/shared/enum_selection.dart';
import 'package:fladder/widgets/shared/item_actions.dart';
import 'package:fladder/screens/shared/animated_fade_size.dart';

Future<void> showSeerrQuickRequestDialog(BuildContext context) {
  return showDialogAdaptive(
    context: context,
    builder: (context) => const SeerrQuickRequestDialog(),
  );
}

class SeerrQuickRequestDialog extends ConsumerStatefulWidget {
  const SeerrQuickRequestDialog({super.key});

  @override
  ConsumerState<SeerrQuickRequestDialog> createState() => _SeerrQuickRequestDialogState();
}

class _SeerrQuickRequestDialogState extends ConsumerState<SeerrQuickRequestDialog> {
  bool _loading = true;
  List<SeerrRadarrServer> _servers = [];

  bool _enableQuickRequest = false;
  int? _selectedServerId;
  int? _selectedProfileId;
  String? _selectedRootFolder;

  @override
  void initState() {
    super.initState();
    final creds = ref.read(userProvider)?.seerrCredentials;
    _enableQuickRequest = creds?.enableQuickRequest ?? false;
    _selectedServerId = creds?.defaultRadarrServerId;
    _selectedProfileId = creds?.defaultRadarrProfileId;
    _selectedRootFolder = creds?.defaultRadarrRootFolder;

    _loadServers();
  }

  Future<void> _loadServers() async {
    try {
      final fetched = await ref.read(seerrApiProvider).radarrServers();
      if (!mounted) return;
      setState(() {
        _servers = fetched;
        if (_selectedServerId == null && _servers.isNotEmpty) {
          final defaultServer = _servers.firstWhereOrNull((s) => s.isDefault == true) ?? _servers.first;
          _selectedServerId = defaultServer.id;
        }
        _ensureValidSelections();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _ensureValidSelections() {
    final server = _servers.firstWhereOrNull((s) => s.id == _selectedServerId);
    if (server != null) {
      if (_selectedProfileId == null || !(server.profiles?.any((p) => p.id == _selectedProfileId) ?? false)) {
        _selectedProfileId = server.activeProfileId ?? server.profiles?.firstOrNull?.id;
      }
      if (_selectedRootFolder == null || !(server.rootFolders?.any((r) => r.path == _selectedRootFolder) ?? false)) {
        _selectedRootFolder = server.activeDirectory ?? server.rootFolders?.firstOrNull?.path;
      }
    }
  }

  void _save() {
    final user = ref.read(userProvider);
    if (user == null || user.seerrCredentials == null) return;

    final updated = user.seerrCredentials!.copyWith(
      enableQuickRequest: _enableQuickRequest,
      defaultRadarrServerId: _selectedServerId,
      defaultRadarrProfileId: _selectedProfileId,
      defaultRadarrRootFolder: _selectedRootFolder,
    );

    ref.read(userProvider.notifier).userState = user.copyWith(seerrCredentials: updated);
    Navigator.of(context).pop();
  }

  String _serverLabel(SeerrServer? server) {
    if (server == null) return context.localized.server;
    final name = server.name;
    final is4k = server.is4k;
    final suffix = is4k == true ? ' (4K)' : '';
    return '${name ?? 'Server'}$suffix';
  }

  Widget _buildConfigSection() {
    final currentServer = _servers.firstWhereOrNull((s) => s.id == _selectedServerId);
    final availableProfiles = currentServer?.profiles ?? [];
    final availableRootFolders = currentServer?.rootFolders ?? [];
    final defaultRootFolder = currentServer?.activeDirectory;

    String rootFolderLabel(BuildContext context, String folder, String? defaultFolder) {
      if (defaultFolder != null && folder == defaultFolder) {
        return context.localized.rootFolderDefaultLabel(folder);
      }
      return folder;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        if (_servers.isNotEmpty)
          EnumSelection(
            label: Text(context.localized.server),
            current: _serverLabel(currentServer),
            itemBuilder: (context) => _servers
                .map(
                  (server) => ItemActionButton(
                    label: Text(_serverLabel(server)),
                    action: () {
                      setState(() {
                        _selectedServerId = server.id;
                        _ensureValidSelections();
                      });
                    },
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 12),
        if (availableProfiles.isNotEmpty)
          EnumSelection(
            label: Text(context.localized.qualityProfile),
            current: availableProfiles.firstWhereOrNull((p) => p.id == _selectedProfileId)?.name ??
                context.localized.selectProfile,
            itemBuilder: (context) => availableProfiles
                .map((profile) => ItemActionButton(
                      label: Text(profile.name ?? context.localized.unknown),
                      action: () {
                        setState(() {
                          _selectedProfileId = profile.id;
                        });
                      },
                    ))
                .toList(),
          ),
        const SizedBox(height: 12),
        if (availableRootFolders.isNotEmpty)
          EnumSelection(
            label: Text(context.localized.rootFolder),
            current: _selectedRootFolder != null
                ? rootFolderLabel(context, _selectedRootFolder!, defaultRootFolder)
                : context.localized.selectFolder,
            itemBuilder: (context) => availableRootFolders
                .map((folder) => ItemActionButton(
                      label: Text(rootFolderLabel(context, folder.path ?? '', defaultRootFolder)),
                      action: () {
                        setState(() {
                          _selectedRootFolder = folder.path;
                        });
                      },
                    ))
                .toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 640,
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Serviço Padrão (Quick Request)",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(IconsaxPlusBold.close_circle),
                ),
              ],
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round)),
              )
            else
              AnimatedFadeSize(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SettingsListTileCheckbox(
                      label: const Text("Habilitar para Filmes"),
                      subLabel: const Text("Pular a janela e requisitar silenciosamente os filmes na sua conta usando as regras predefinidas."),
                      value: _enableQuickRequest,
                      onChanged: (val) {
                        setState(() {
                          _enableQuickRequest = val ?? false;
                        });
                      },
                    ),
                    if (_enableQuickRequest) _buildConfigSection(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton(
                          onPressed: _save,
                          child: Text(context.localized.save),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
