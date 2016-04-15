require 'rails_helper'

describe Tabulatr::Renderer do

  class FakeRendererSpecTabulatrData < Tabulatr::Data
    filter :simple_filter
    target_class Product
  end

  def double_view
    view = double(controller: double(controller_name: 'products', action_name: 'index'), render: '')
    view.instance_variable_set('@_tabulatr_table_index', 0)
    view
  end

  describe '.initialize' do
    it 'sets pagination_position to top if not set explicitely' do
      renderer = Tabulatr::Renderer.new(Product, double_view)
      expect(renderer.instance_variable_get('@table_options')[:pagination_position]).to eq :top
    end

    it 'sets persistent to true if not set explicitely' do
      renderer = Tabulatr::Renderer.new(Product, double_view)
      expect(renderer.instance_variable_get('@table_options')[:persistent]).to eq true
    end

    it 'sets persistent to true if paginate is true' do
      renderer = Tabulatr::Renderer.new(Product, double_view, paginate: true)
      expect(renderer.instance_variable_get('@table_options')[:persistent]).to eq true
    end
  end

  describe '#build_table' do
    it 'gets columns by their names' do
      renderer = Tabulatr::Renderer.new(Product, double_view)
      renderer.build_table(['_buttons'], [], 'ProductTabulatrData')
      columns = renderer.instance_variable_get('@columns')
      expect(columns.count).to be(1)
      expect(columns.first).to be_instance_of(Tabulatr::Renderer::Buttons)
    end

    it 'gets filters by their names' do
      allow_any_instance_of(Tabulatr::Data).to receive(:table_columns).and_return([])
      renderer = Tabulatr::Renderer.new(Product, double_view)
      renderer.build_table([], [:simple_filter], 'FakeRendererSpecTabulatrData')
      filters = renderer.instance_variable_get('@filters')
      expect(filters.map(&:name)).to match_array([:simple_filter])
    end

    it 'renders no custom filters if `filters` option is false' do
      allow_any_instance_of(Tabulatr::Data).to receive(:table_columns).and_return([])
      renderer = Tabulatr::Renderer.new(Product, double_view)
      renderer.build_table([], false, 'FakeRendererSpecTabulatrData')
      filters = renderer.instance_variable_get('@filters')
      expect(filters).to be_nil
    end
  end
end
