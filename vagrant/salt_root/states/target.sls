site:
  grains:
    - present
    - value: dev

deployment_target:
  grains:
    - present
    - value: mediawiki/slot0

sync_returners:
  module.run:
    - name: saltutil.sync_returners

sync_all_from_master:
  module.run:
    - name: saltutil.sync_all
