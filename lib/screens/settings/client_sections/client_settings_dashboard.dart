import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/models/settings/home_settings_model.dart';
import 'package:fladder/providers/settings/client_settings_provider.dart';
import 'package:fladder/providers/settings/home_settings_provider.dart';
import 'package:fladder/screens/settings/settings_list_tile.dart';
import 'package:fladder/screens/settings/widgets/settings_label_divider.dart';
import 'package:fladder/screens/settings/widgets/settings_list_group.dart';
import 'package:fladder/util/localization_helper.dart';
import 'package:fladder/widgets/shared/item_actions.dart';

List<Widget> buildClientSettingsDashboard(BuildContext context, WidgetRef ref) {
  final clientSettings = ref.watch(clientSettingsProvider);
  return settingsListGroup(
    context,
    SettingsLabelDivider(label: context.localized.dashboard),
    [
      SettingsListTileEnum(
        label: Text(context.localized.settingsHomeBannerTitle),
        subLabel: Text(context.localized.settingsHomeBannerDescription),
        current: ref.watch(
          homeSettingsProvider.select(
            (value) => value.homeBanner.label(context),
          ),
        ),
        itemBuilder: (context) => HomeBanner.values
            .map(
              (entry) => ItemActionButton(
                label: Text(entry.label(context)),
                action: () =>
                    ref.read(homeSettingsProvider.notifier).update((context) => context.copyWith(homeBanner: entry)),
              ),
            )
            .toList(),
      ),
      if (ref.watch(homeSettingsProvider.select((value) => value.homeBanner)) != HomeBanner.hide)
        SettingsListTileEnum(
          label: Text(context.localized.settingsHomeBannerInformationTitle),
          subLabel: Text(context.localized.settingsHomeBannerInformationDesc),
          current: ref.watch(
            homeSettingsProvider.select((value) => value.carouselSettings.label(context)),
          ),
          itemBuilder: (context) => HomeCarouselSettings.values
              .map(
                (entry) => ItemActionButton(
                  label: Text(entry.label(context)),
                  action: () => ref
                      .read(homeSettingsProvider.notifier)
                      .update((context) => context.copyWith(carouselSettings: entry)),
                ),
              )
              .toList(),
        ),
      SettingsListTileEnum(
        label: Text(context.localized.settingsHomeNextUpTitle),
        subLabel: Text(context.localized.settingsHomeNextUpDesc),
        current: ref.watch(
          homeSettingsProvider.select(
            (value) => value.nextUp.label(context),
          ),
        ),
        itemBuilder: (context) => HomeNextUp.values
            .map(
              (entry) => ItemActionButton(
                label: Text(entry.label(context)),
                action: () =>
                    ref.read(homeSettingsProvider.notifier).update((context) => context.copyWith(nextUp: entry)),
              ),
            )
            .toList(),
      ),
      SettingsListTile(
        label: Text(context.localized.clientSettingsShowAllCollectionsTitle),
        subLabel: Text(context.localized.clientSettingsShowAllCollectionsDesc),
        onTap: () => ref
            .read(clientSettingsProvider.notifier)
            .update((current) => current.copyWith(showAllCollectionTypes: !current.showAllCollectionTypes)),
        trailing: Switch(
          value: clientSettings.showAllCollectionTypes,
          onChanged: (value) => ref
              .read(clientSettingsProvider.notifier)
              .update((current) => current.copyWith(showAllCollectionTypes: value)),
        ),
      ),
      SettingsListTile(
        label: const Text("Ocultar Lançamentos Recentes (Seerr)"),
        subLabel: const Text("Esconde filmes que ainda não saíram do cinema e séries futuras."),
        onTap: () => ref
            .read(clientSettingsProvider.notifier)
            .update((current) => current.copyWith(seerrHideUnreleased: !current.seerrHideUnreleased)),
        trailing: Switch(
          value: clientSettings.seerrHideUnreleased,
          onChanged: (value) => ref
              .read(clientSettingsProvider.notifier)
              .update((current) => current.copyWith(seerrHideUnreleased: value)),
        ),
      ),
      if (clientSettings.seerrHideUnreleased)
        SettingsListTile(
          label: const Text("Dias de Atraso para Filmes"),
          subLabel: Text("Esconder filmes lançados nos últimos ${clientSettings.seerrDigitalReleaseDelay} dias."),
          trailing: SizedBox(
            width: 150,
            child: Slider(
              value: clientSettings.seerrDigitalReleaseDelay.toDouble(),
              min: 0,
              max: 90,
              divisions: 90,
              label: clientSettings.seerrDigitalReleaseDelay.toString(),
              onChanged: (value) => ref
                  .read(clientSettingsProvider.notifier)
                  .update((current) => current.copyWith(seerrDigitalReleaseDelay: value.toInt())),
            ),
          ),
        ),
    ],
  );
}
