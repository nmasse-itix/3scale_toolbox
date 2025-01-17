module ThreeScaleToolbox
  module Tasks
    class CopyLimitsTask
      include CopyTask
      include Helper

      def call
        metrics_map = metrics_mapping(source.metrics, target.metrics)
        plan_mapping = application_plan_mapping(source.plans, target.plans)
        plan_mapping.each do |plan_id, target_plan|
          limits = source.plan_limits(plan_id)
          limits_target = target.plan_limits(target_plan['id'])
          missing_limits = missing_limits(limits, limits_target)
          missing_limits.each do |limit|
            limit.delete('links')
            target.create_application_plan_limit(
              target_plan['id'],
              metrics_map.fetch(limit.fetch('metric_id')),
              limit
            )
          end
          puts "Missing #{missing_limits.size} plan limits from target application plan " \
            "#{target_plan['id']}. Source plan #{plan_id}"
        end
      end

      private

      def missing_limits(source_limits, target_limits)
        ThreeScaleToolbox::Helper.array_difference(source_limits, target_limits) do |limit, target|
          ThreeScaleToolbox::Helper.compare_hashes(limit, target, ['period'])
        end
      end
    end
  end
end
