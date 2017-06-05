# Simple Ping Results

simple ping results collecting system using fping and ruby (sinatra, hamlit, sequel, clockwork)

## How to use

- Install `fping` (`sudo apt install fping`, `brew install fping`, etc.)
- `git clone https://github.com/znz/simple-ping-results`
- `cd simple-ping-results`
- `bundle install --path .bundle/vendor --without postgres`
- `bundle exec rake db:migrate DATABASE_URL=sqlite://development.db` or `rake db:migrate DATABASE_URL=sqlite://development.db`
- `bundle exec irb -r irb/completion -r ./app` and `Target.create(range: '192.168.1.x', min: 1, max: 254, group: 'LAN')` and/or `Target.create(range: '192.168.x.1', min: 0, max: 255, group: 'LAN')`, etc.
  - `range: '192.168.1.x', min: 1, max: 254` means `192.168.1.1-254`
  - `range: '192.168.x.1', min: 0, max: 255` means `192.168.0.255.1`
- `BASIC_AUTH_USERNAME=admin BASIC_AUTH_PASSWORD=admin bundle exec foreman start`
- `open http://localhost:5000/`

## Import data of simple-ping-summary

Import data of [simple-ping-summary](https://github.com/znz/simple-ping-summary).

Example:

- `ruby import.rb 192.168.1.x 1 254 /path/to/data/192.168.1`
- `ruby import.rb 192.168.x.1 1 255 /path/to/data/192.168`

## Using in Dokku

- Install [Dokku](http://dokku.viewdocs.io/dokku/)
- `dokku apps:create ping`
- `dokku config:set --no-restart ping TZ=Asia/Tokyo`
- `dokku config:set --no-restart ping BASIC_AUTH_USERNAME=admin BASIC_AUTH_PASSWORD=admin`
- `sudo dokku plugin:install https://github.com/dokku/dokku-postgres`
- `dokku postgres:create ping-db`
- `dokku postgres:link ping-db ping`
- `sudo dokku plugin:install https://github.com/F4-Group/dokku-apt`
- `git push dokku@dokku.me:ping master`
- `dokku ps:scale ping clock=1`
