# frozen_string_literal: true

require 'generator_spec'
require 'generators/matestack/core/component/component_generator'

describe Matestack::Core::Generators::ComponentGenerator, type: :generator do

  after :each do
    FileUtils.rm_rf('spec/dummy/tmp/app') if File.exists?('spec/dummy/tmp/app')
    FileUtils.rm_rf('spec/dummy/tmp/docs') if File.exists?('spec/dummy/tmp/docs')
    FileUtils.rm_rf('spec/dummy/tmp/spec') if File.exists?('spec/dummy/tmp/spec')
  end

  destination "#{Rails.root}/tmp"

  it 'creates a core component' do
    run_generator %w(div)

    assert_file 'app/concepts/matestack/ui/core/div/div.rb', /module Matestack::Ui::Core::Div/
    assert_file 'app/concepts/matestack/ui/core/div/div.rb', /class Div < Matestack::Ui::Core::Component::Static/

    assert_file 'app/concepts/matestack/ui/core/div/div.haml', /%div{@tag_attributes}/

    assert_file 'spec/usage/components/div_spec.rb', /describe 'Div component', type: :feature, js: true do/
    assert_file 'spec/usage/components/div_spec.rb', /div text: 'Simple div tag'/
    assert_file 'spec/usage/components/div_spec.rb', %r{<div>Simple div tag</div>}
    assert_file 'spec/usage/components/div_spec.rb', /div id: 'my-id', class: 'my-class' do/
    assert_file 'spec/usage/components/div_spec.rb', %r{<div id="my-id" class="my-class">Enhanced div tag</div>}

    assert_file 'docs/components/div.md', /# matestack core component: Div/
    assert_file 'docs/components/div.md', %r{Show \[specs\]\(/spec/usage/components/div_spec.rb\)}
    assert_file 'docs/components/div.md', /The HTML `<div>` tag implemented in ruby./
    assert_file 'docs/components/div.md', /Expects a string with all ids the `<div>` should have./
    assert_file 'docs/components/div.md', /Expects a string with all classes the `<div>` should have./
    assert_file 'docs/components/div.md', /div id: 'foo', class: 'bar' do/
    assert_file 'docs/components/div.md', /div id: 'foo', class: 'bar', text: 'Div example 2'/
    assert_file 'docs/components/div.md', /<div id="foo" class="bar">/
  end
end
