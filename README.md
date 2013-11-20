Trebuchet
=========

Trebuchet is a two-phase deployment system with reporting implemented using Salt Stack. Its primary transportation method uses git.

Design
------

TODO: Add design documentation

Prerequisites
-------------

Salt Stack is a hard requirement.

A mininum of two nodes is required: salt master/deployment server and a deployment target. It is recommended that the salt master is split apart from the deployment server.

Installation
------------

### Using Salt Stack ###

Include the salt states, based on the node type:

salt master: deployment.salt\_master
deployment server: deployment.deployment\_server
deployment target: deployment.deployment\_target

Note: It's best to include deployment.deployment\_target from states that configure your targets. For instance, if you are running MediaWiki, you should include this state from the state that installs MediaWiki's prerequisites.

TODO: Add these salt states to the repo

### Using puppet ###

Using the trebuchet puppet module (https://github.com/trebuchet-deploy/puppet).

TODO: Add puppet module documentation

Configuration
-------------

All of Trebuchet is configured using Salt Pillars. Two pillars are used, deployment\_config and repo\_config.

deployment\_config:

*parent\_dir (default: none; required)*
    A string that defines the parent directory for all repositories on both the deployment server and the targets. A repo of name test/testrepo would reside at <parent_dir>/test/testrepo.
*servers (default: none; required)*
    A hash that defines datacenter to deployment server mappings.
*redis (default: none; required)*
    A hash that defines redis information; required fields: host, port, db

repo\_config:

*grain (default: none; required)*
    A string that defines the grain this repo targets. This should be the same value used in the deployment::target definition for the hosts in puppet. 
*upstream (default: none)*
    A string that defines the url of the upstream repo associated with this deployment repo. This is used to initialize the repo on the deployment server. If no upstream is defined then an empty repository will be created. 
*shadow\_reference (default: false)*
    A boolean that defines whether or not this repo will create a reference clone of this repo during the fetch stage. Example: test/testrepo would also have a test/.testrepo clone on the targets that is fully checked out to the deployment tag during the fetch stage. 
*fetch\_module\_calls (default: {})*
    A hash of salt modules with a list of arguments that will get called on the minion at the end of the fetch stage of deployment. 
*checkout\_module\_calls (default: {})*
    A hash of salt modules with a list of arguments that will get called on the minion at the end of the checkout stage of deployment. The following argument expansions exist: \_\_REPO\_\_ expands to the name of the repo. 
*checkout\_submodules (default: false)*
    A boolean that defines whether or not this repo should also do submodule actions. The following argument expansions exist: \_\_REPO\_\_ expands to the name of the repo. 
*location (default: /srv/deployment/<repo-name>)*
    The string location of the repository on the deployment system and on the minion. You should avoid setting this unless you really know what you are doing.
*sync\_script (default: shared.py)*
    A string that defines the sync script used for this repository. Options are depends.py and shared.py. This is used by the git-deploy hooks and is otherwise unused.
*dependencies (default: {})*
    A hash of repositories with dependency scripts that this repository depends on. These repositories will be deployed automatically before this repository. Example to add the l10n-slot0 dependency for a repo, with that dependency using the l10n dependency script: {'l10n-slot0' => 'l10n'}. Dependencies are awkward and should be avoided if possible. 
*automated (default: false)*
    A boolean that defines whether or not this repository is automatically or manually deployed. This is used by the git-deploy hooks and is otherwise unused.

Usage
-----

Currently Trebuchet must be used in combination with a deployment frontend called git-deploy:

  https://github.com/git-deploy/git-deploy

Soon it will also be usable with the python fork of git-deploy:

  https://github.com/Git-Tools/git-deploy

Future plans will allow the use of Trebuchet through a web frontend, or directly using git in a Heroku-like workflow.

Assuming you've installed git-deploy support as described in the Installation section, the basic use of trebuchet is controlled through git-deploy:

```bash
git deploy start
<git changes you'd like to make>
git deploy sync
```
