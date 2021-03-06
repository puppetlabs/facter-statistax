# Steps for collecting facter statistics

1. ```bundle install```
2.  ```export SHA=6.0.9``` - puppet agent SHA/VERSION to be installed and tested (please note that this projects 
is working with puppet agent >= 6.0.x)
3. ```export GEM_VERSION=2.5.5``` - gem facter version you want to test (if this env variable isn't set, the latest
version will be downloaded)
4. Modify config.json from acceptance directory to meet your testing needs
5. To test using vmpooler:\
```beaker-hostgenerator redhat7-64a-debian9-64a > hosts.yaml```\
```beaker init -h hosts.yaml --options-file config/aio/options.rb```\
   To test using nspooler you have to require the vm from nspooler first, then:\
```beaker-hostgenerator centos6-64a-solaris11-SPARC\{hypervisor=none\,hostname=$THE_HOST_NSPOOLER_PROVIDED\} > hosts.yaml```\
```bundle exec beaker init --hosts hosts.yaml --options-file config/aio/options.rb```
6. ```bundle exec beaker provision```
7. ```bundle exec beaker exec pre-suite --pre-suite presuite/01_install_puppet_agent.rb,presuite/02_install_facter_statistax.rb,presuite/03_install_facter_gem.rb --preserve-state```
8. ```bundle exec beaker exec run/run_statistax.rb```
