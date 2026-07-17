require_relative 'auth_session'

Before do |scenario|
  tags = scenario.source_tag_names
  @request_headers = {}
  public_scenario = tags.include?('@public')
  authenticated_scenario = tags.include?('@authenticated')

  if public_scenario && authenticated_scenario
    raise 'Cenário não pode ser @public e @authenticated ao mesmo tempo.'
  end

  unless public_scenario || authenticated_scenario
    raise 'Cenário deve possuir a tag @public ou @authenticated.'
  end

  @request_headers.merge!(AuthSession.auth_headers) if authenticated_scenario
end
