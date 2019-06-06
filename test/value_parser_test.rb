require "test_helper"

class FilterTest < ActiveSupport::TestCase
  test "returns the original value without options" do
    parser = Sift::ValueParser.new(value: "hi")

    assert_equal "hi", parser.parse
  end

  test "With options an array of integers results in an array of integers" do
    parser = Sift::ValueParser.new(value: [1, 2, 3])

    assert_equal [1, 2, 3], parser.parse
  end

  test "With options a json string array of integers results in an array of integers" do
    options = {
      supports_ranges: true,
      supports_json: true
    }
    parser = Sift::ValueParser.new(value: "[1,2,3]", options: options)

    assert_equal [1, 2, 3], parser.parse
  end

  test "with invalid json returns original value" do
    options = {
      supports_ranges: true,
      supports_json: true
    }
    parser = Sift::ValueParser.new(value: "[1,2,3", options: options)

    assert_equal "[1,2,3", parser.parse
  end

  test "JSON parsing only supports arrays" do
    options = {
      supports_json: true
    }
    json_string = "{\"a\":4}"
    parser = Sift::ValueParser.new(value: json_string, options: options)

    assert_equal json_string, parser.parse
  end

  test "With options a range string of integers results in a range" do
    options = {
      supports_ranges: true,
      supports_json: true
    }
    parser = Sift::ValueParser.new(value: "1...3", options: options)

    assert_instance_of Range, parser.parse
  end

  test "parses true from 1" do
    options = {
      supports_boolean: true
    }
    parser = Sift::ValueParser.new(value: 1, options: options)

    assert_equal true, parser.parse
  end

  test "parses false from 0" do
    options = {
      supports_boolean: true
    }
    parser = Sift::ValueParser.new(value: 0, options: options)

    assert_equal false, parser.parse
  end

  test "parses range for range values" do
    options = {
      supports_ranges: true
    }
    test_sets = [
      {
        type: :date,
        start_value: '2008-06-21',
        end_value: '2008-06-22'
      },
      {
        type: :time,
        start_value: '13:30:00',
        end_value: '13:45:00'
      },
      {
        type: :boolean,
        start_value: true,
        end_value: false
      },
      {
        type: :int,
        start_value: 3,
        end_value: 20
      },
      {
        type: :decimal,
        start_value: 123.456,
        end_value: 44.55
      },
      {
        start_value: 'any',
        end_value: 'value'
      }
    ]

    test_sets.each do |set|
      range_string = "#{set[:start_value]}...#{set[:end_value]}"
      parser = Sift::ValueParser.new(value: range_string, type: set[:type], options: options)

      result = parser.parse
      assert_instance_of Range, result
      assert_equal result.last, set[:end_value].to_s
    end
  end

  test "parses range for Date string range and normalizes DateTime values" do
    options = {
      supports_ranges: true
    }

    start_date = "2018-01-01T10:00:00Z[Etc/UTC]"
    end_date = "2018-01-01T12:00:00Z[Etc/UTC]"
    range_string = "#{start_date}...#{end_date}"
    parser = Sift::ValueParser.new(value: range_string, type: :datetime, options: options)

    result = parser.parse
    assert_instance_of Range, result
    assert_equal DateTime.parse(result.last), DateTime.parse(end_date)
  end
end
