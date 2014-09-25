base:
  '*':
    - common
    - order: 1
  'service_name:saltmaster':
    - saltmaster
    - match: grain
    - order: 10
  'service_name:ricochet':
    - ricochet
    - match: grain
    - order: 10
