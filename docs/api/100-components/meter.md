# Matestack Core Component: Meter

Use the Meter component to implement `<meter>` tag.

## Parameters

#### value (required)
Expects a number thats is the current value of the gauge.

#### id (optional)
Expects a string with all ids the meter should have.

#### class (optional)
Expects a string with all classes the meter should have.

#### min (optional)
Expects a number that defines the minimum value of the range.

#### max (optional)
Expects a number that defines the maximum value of the range.

#### low (optional)
Expects a number that defines which value is considered a low value

#### high (optional)
Expects a number that defines which value is considered a high value

#### optimum (optional)
Expects a number that defines which value is optimal for the gauge


## Example

```ruby
meter id: 'meter_id', value: 0.6

meter id: 'meter', min: 0, max: 10, value: 6 do
	plain '6 out of 10. 60%.'
end

meter id: 'meter', low: 2, high: 8, optimum: 6, min: 0, max: 10, value: 6 do
	plain '6 out of 10. 60%.'
end
```

returns

```html
<meter id="meter_id" value="0.6"></meter>

<meter id="meter" max="10" min="0" value="6">6 out of 10. 60%.</meter>

<meter high="8" id="meter" low="2" max="10" min="0" optimum="6" value="6">
	6 out of 10. 60%.
</meter>
```
