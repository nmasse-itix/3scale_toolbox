require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Tasks::CopyPricingRulesTask do
  context '#call' do
    let(:source) { double('source') }
    let(:target) { double('target') }
    let(:source_remote) { double('source_remote') }
    let(:target_remote) { double('target_remote') }
    let(:plan_0) { { 'id' => 0, 'name' => 'plan_0', 'system_name' => 'plan_0' } }
    let(:plan_1) { { 'id' => 1, 'name' => 'plan_1', 'system_name' => 'plan_1' } }
    let(:metric_0) { { 'id' => 0, 'name' => 'metric_0', 'system_name' => 'metric_0' } }
    let(:metric_1) { { 'id' => 1, 'name' => 'metric_0', 'system_name' => 'metric_0' } }
    let(:pricing_rule_0) do
      {
        'id' => 1,
        'name' => 'pr_1',
        'system_name' => 'pr_1',
        'metric_id' => 0
      }
    end
    let(:source_plans) { [plan_0] }
    let(:target_plans) { [plan_0] }

    subject { described_class.new(source: source, target: target) }

    before :each do
      allow(source).to receive(:remote).and_return(source_remote)
      allow(target).to receive(:remote).and_return(target_remote)
      expect(source).to receive(:plans).and_return(source_plans)
      expect(source).to receive(:metrics).and_return([metric_0])
      expect(target).to receive(:plans).and_return(target_plans)
      expect(target).to receive(:metrics).and_return([metric_1])
    end

    context 'no application plan match' do
      # missing plans is empty set
      let(:target_plans) { [plan_1] }

      it 'does not call create_application_plan_limit method' do
        subject.call
      end
    end

    context 'no pricingrules match' do
      let(:source_pricingrules) { [] }
      let(:target_pricingrules) { [] }
      before :each do
        expect(source_remote).to receive(:list_pricingrules_per_application_plan).and_return(source_pricingrules)
        expect(target_remote).to receive(:list_pricingrules_per_application_plan).and_return(target_pricingrules)
      end

      # missing_pricingrules is an empty set
      it 'does not call create_pricingrule method' do
        expect { subject.call }.to output(/Missing 0 pricing rules/).to_stdout
      end
    end

    context 'pricingrules match' do
      let(:source_pricingrules) { [pricing_rule_0] }
      let(:target_pricingrules) { [] }
      before :each do
        expect(source_remote).to receive(:list_pricingrules_per_application_plan).and_return(source_pricingrules)
        expect(target_remote).to receive(:list_pricingrules_per_application_plan).and_return(target_pricingrules)
      end

      # missing_pricingrules is an empty set
      it 'does not call create_pricingrule method' do
        expect(target_remote).to receive(:create_pricingrule).with(plan_0['id'],
                                                                   metric_1['id'],
                                                                   pricing_rule_0)
        expect { subject.call }.to output(/Missing 1 pricing rules/).to_stdout
      end
    end
  end
end
