FactoryGirl.define do
  factory :stack, :class => ForemanDeployments::Stack do
    sequence(:name) { |n| "stack_#{n}" }
    definition [
      'Task1: !task:FakeTask',
      '  hardcoded_param: hardcoded',
      'Task2: !task:FakeTask'
    ].join("\n")

    trait :with_taxonomy do
      organizations do
        [FactoryGirl.create(:organization)]
      end
      locations do
        [FactoryGirl.create(:location)]
      end
    end
  end

  factory :configuration, :class => ForemanDeployments::Configuration do
  end

  factory :deployment, :class => ForemanDeployments::Deployment do
    sequence(:name) { |n| "deployment_#{n}" }
    transient do
      stack nil
    end

    after(:build) do |deployment, evaluator|
      unless evaluator.stack.nil?
        deployment.configuration = FactoryGirl.build(:configuration, :stack => evaluator.stack)
      end
    end

    trait :with_stack do
      stack do
        FactoryGirl.create(:stack)
      end

      after(:build) do |deployment, _evaluator|
        deployment.stack.organizations << deployment.organization
        deployment.stack.locations << deployment.location
      end
    end

    trait :with_stack_taxonomy do
      after(:build) do |deployment, _evaluator|
        deployment.organization = deployment.stack.organizations.first
        deployment.location = deployment.stack.locations.first
      end
    end

    trait :with_taxonomy do
      organization do
        FactoryGirl.create(:organization)
      end
      location do
        FactoryGirl.create(:location)
      end
    end
  end
end
