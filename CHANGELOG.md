network_interface
=================

v1.0.0 (2014-03-03)
-------------------

- released version on community


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
