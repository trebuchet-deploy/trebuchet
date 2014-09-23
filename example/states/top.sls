base:
  '*':
    - common
    - order: 1
  'service_name:saltmaster':
    - saltmaster
    - order: 10
  'service_name:ricochet':
    - ricochet
    - order: 10
