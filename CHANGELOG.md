network_interface
=================
## 1.0.2 - *2021-06-01*

- resolved cookstyle error: Berksfile:1:1 refactor: `ChefModernize/LegacyBerksfileSource`
- resolved cookstyle error: libraries/matchers.rb:1:1 refactor: `ChefModernize/DefinesChefSpecMatchers`
- resolved cookstyle error: metadata.rb:6:1 refactor: `ChefRedundantCode/LongDescriptionMetadata`
- resolved cookstyle error: providers/default.rb:1:1 refactor: `ChefModernize/WhyRunSupportedTrue`
- resolved cookstyle error: providers/default.rb:5:1 warning: `ChefDeprecations/UseInlineResourcesDefined`
- resolved cookstyle error: providers/default.rb:8:8 warning: `ChefDeprecations/NodeSet`
- resolved cookstyle error: recipes/default.rb:2:1 refactor: `ChefStyle/CommentFormat`
- resolved cookstyle error: recipes/default.rb:8:1 refactor: `ChefStyle/CommentFormat`
- resolved cookstyle error: recipes/default.rb:9:1 refactor: `ChefStyle/CommentFormat`
- resolved cookstyle error: recipes/default.rb:25:6 warning: `ChefDeprecations/NodeSet`
- Add `network_interfaces_eni` resource (#32)


# 1.0.2 - *2021-06-01*:

- Add custom matchers for `network_interface` LWRP (#21)
- Drop very old Debian support (#14)
- Refactor linting, syntax checking, and unit testing (#29)
    + Includes a tweak to work on Ubuntu 16.04
    + Updates testing to latest two versions of Debian & Ubuntu
- Add features & better errors to LWRP (#30)
- Add support for the [`allow-hotplug` stanza](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_basic_syntax_of_etc_network_interfaces) mainly used in Debian.

# Last Release: v1.0.0

v1.0.0 (2014-03-03)
-------------------
- Released version on community

v1.0.0 (2014-02-24=5)
-------------------
- Bump version to 1.0.0 to reflect production-level usage
- Adjust support to be Ubuntu >= 12.04
- Add more comprehensive testing, using:
    - Rubocop
    - Foodcritic (just cleaned things up)
    - Test Kitchen (integration tests!)
- Cleaned up some lingering Foodcritic issues
    - LWRP notifications
    - Unknown resource attributes due to slightly funky syntax
- Satisfied Rubocop with some comments
- Fixed syntax error introduced in 0.3.1 with the ternary
- Add Ruby 2.x testing to Travis config
- Fix issue with ever-expanding `node['network_interfaces']['order']`

v0.3.1 (2014-02-24)
-------------------
- Clean up code, following Rubocop’s suggestions

v0.3.0 (2013-11-13)
-------------------
- Refactor & streamline much of the code

v0.2.2 (2014-02-07)
-------------------
- fix foodcritic
- fix directory permissions

v0.2.0 (2013-04-04)
-------------------
- Initial changelog
