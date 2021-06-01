# Pronto runner for Reek

[![Code Climate](https://codeclimate.com/github/prontolabs/pronto-reek.png)](https://codeclimate.com/github/prontolabs/pronto-reek)
[![Build Status](https://travis-ci.org/prontolabs/pronto-reek.png)](https://travis-ci.org/prontolabs/pronto-reek)
[![Gem Version](https://badge.fury.io/rb/pronto-reek.png)](http://badge.fury.io/rb/pronto-reek)
[![Dependency Status](https://gemnasium.com/prontolabs/pronto-reek.png)](https://gemnasium.com/prontolabs/pronto-reek)

Pronto runner for [Reek](https://github.com/troessner/reek), code smell detector for Ruby. [What is Pronto?](https://github.com/prontolabs/pronto)

## Configuration

Configuring Reek via [config.reek](https://github.com/troessner/reek#configuration-file), or any file ending with .reek, will work just fine with pronto-reek.

You can also specify a custom severity level for the reek smells with the environment variable PRONTO_REEK_SEVERITY_LEVEL.

Or if you prefer provide it on your `.pronto.yml` (environment variable has precedence over file):

```yaml
reek:
  severity_level: warning # default is info
```
