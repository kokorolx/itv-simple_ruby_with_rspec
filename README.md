# pv_logivan_nov_2019
The interface to our checkout looks like this (shown in Ruby):
```ruby
co = Checkout.new(promotional_rules)
co.scan(item)
co.scan(item)
price = co.total
```
## How to run:
```bash
sudo gem install rspec
# Run rspec:
rspec 
```
Test data
---------
```ruby
Basket: 001,002,003
Total price expected: £66.78
Basket: 001,003,001
Total price expected: £36.95
Basket: 001,002,001,003
Total price expected: £73.76
```
