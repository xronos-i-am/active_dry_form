# frozen_string_literal: true

require_relative 'app/user'
require_relative 'app/personal_info'
require_relative 'app/nested_has_one_form'

RSpec.describe ActiveDryForm do
  let(:user) { User.create!(name: 'Ivan') }

  context 'when nested form is invalid' do
    it 'returns validation errors' do
      form = NestedHasOneForm.new(record: user, params: { user: { personal_info: { age: '' } } })
      form.update
      expect(form.errors).to eq({ personal_info: { age: ['должно быть заполнено'] } })
    end
  end

  context 'when nested form is valid' do
    let(:user_params) do
      {
        user: {
          personal_info: {
            age: '20',
            'date_of_birth(3i)': 31,
            'date_of_birth(2i)': 1,
            'date_of_birth(1i)': 2000,
          }
        }
      }
    end
    let(:form) { NestedHasOneForm.new(record: user, params: user_params) }

    it 'creates nested model' do
      form.update
      expect(user.personal_info.age).to eq 20
      expect(user.personal_info.date_of_birth).to eq Date.new(2000, 1, 31)
    end

    it 'updates nested model' do
      user.create_personal_info!(age: 18, date_of_birth: Date.new(1990))
      expect { form.update }
        .to change { user.personal_info.age }.to(20)
        .and change { user.personal_info.date_of_birth }.to(Date.new(2000, 1, 31))
    end
  end
end
