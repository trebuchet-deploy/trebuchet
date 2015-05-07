base:
  deploy:
    - states.deploy
  target:
    - states.target
    - states.deployment.sync_all
