require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Tasks::CopyLimitsTask do
  context '#call' do
    let(:source) { double('source') }
    let(:target) { double('target') }
    let(:plan_0) do
      {
        'id' => 0,
        'name' => 'plan_0',
        'state' => 'published',
        'default' => false,
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'custom' => false,
        'system_name' => 'plan_0',
        'links' => []
      }
    end
    let(:plan_1) do
      {
        'id' => 1,
        'name' => 'plan_1',
        'state' => 'published',
        'default' => false,
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'custom' => false,
        'system_name' => 'plan_1',
        'links' => []
      }
    end
    let(:metric_0) do
      {
        'id' => 0,
        'name' => 'metric_0',
        'system_name' => 'the_metric',
        'unit': '1',
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'links' => []
      }
    end
    let(:metric_1) do
      {
        'id' => 1,
        'name' => 'metric_1',
        'system_name' => 'the_metric',
        'unit': '1',
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'links' => []
      }
    end
    let(:limit_0) do
      { # limit for metric_0
        'id' => 0,
        'period' => 'year',
        'value' => 10_000,
        'metric_id' => 0,
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'links' => []
      }
    end
    let(:source_plans) { [plan_0] }
    let(:source_metrics) { [metric_0] }

    subject { described_class.new(source: source, target: target) }

    before :each do
      expect(source).to receive(:plans).and_return(source_plans)
      expect(source).to receive(:metrics).and_return(source_metrics)
      expect(target).to receive(:plans).and_return(target_plans)
      expect(target).to receive(:metrics).and_return(target_metrics)
    end

    context 'no application plan match' do
      # missing plans is empty set
      let(:target_plans) { [plan_1] }
      let(:target_metrics) { [metric_0] }

      it 'does not call create_application_plan_limit method' do
        subject.call
      end
    end

    context 'no limit match' do
      # missing limits set is empty
      let(:source_limits) { [limit_0] }
      let(:target_plans) { [plan_0] }
      let(:target_metrics) { [metric_0] }
      let(:target_limits) { [limit_0] }

      before :each do
        expect(source).to receive(:plan_limits).with(0).and_return(source_limits)
        expect(target).to receive(:plan_limits).with(0).and_return(target_limits)
      end

      it 'does not call create_application_plan_limit method' do
        expect { subject.call }.to output(/Missing 0 plan limits/).to_stdout
      end
    end

    context '1 limit missing' do
      let(:source_limits) { [limit_0] }
      let(:target_plans) { [plan_0] }
      let(:target_metrics) { [metric_1] }
      let(:target_limits) { [] }

      before :each do
        expect(source).to receive(:plan_limits).with(0).and_return(source_limits)
        expect(target).to receive(:plan_limits).with(0).and_return(target_limits)
      end

      it 'calls create_application_plan_limit method' do
        expect(target).to receive(:create_application_plan_limit).with(plan_0['id'],
                                                                       metric_1['id'],
                                                                       limit_0)
        expect { subject.call }.to output(/Missing 1 plan limits/).to_stdout
      end
    end
  end
end
