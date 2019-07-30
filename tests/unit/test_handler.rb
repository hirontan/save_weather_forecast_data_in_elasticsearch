require 'json'
require 'test/unit'
require 'mocha/test_unit'

require_relative '../../hello_world/app'

class SaveWeatherForecastDataInElasticsearchTest < Test::Unit::TestCase
  def event
    { }
  end

  def expected_result
    { }
  end

  def test_lambda_handler
    assert_equal(lambda_handler(event: event, context: ''), expected_result)
  end
end
