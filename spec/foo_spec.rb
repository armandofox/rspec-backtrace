class Foo ; end

describe Foo do
  test_case_name = Time.parse "12:00pm"
  # test_case_name = "12:00 pm"
  specify test_case_name do
    raise 'Fail'
  end
end
