require 'rails_helper'

describe ResultStatisticSectionPolicy, type: :controller do
  let(:non_member) { FactoryBot.create(:user) }
  let(:leader) { FactoryBot.create(:user) }
  let(:consolidator) { FactoryBot.create(:user) }
  let(:contributor) { FactoryBot.create(:user) }
  let(:auditor) { FactoryBot.create(:user) }
  let(:project) do
    FactoryBot.create(:project).tap do |project|
      project.users << [leader, consolidator, contributor, auditor]
      ProjectsUser.where(project: project, user: leader).first
                  .roles << Role.where(name: 'Leader').first
      ProjectsUser.where(project: project, user: consolidator).first
                  .roles << Role.where(name: 'Consolidator').first
      ProjectsUser.where(project: project, user: contributor).first
                  .roles << Role.where(name: 'Contributor').first
      ProjectsUser.where(project: project, user: auditor).first
                  .roles << Role.where(name: 'Auditor').first
    end
  end

  before { sign_in user }

  subject { ResultStatisticSectionPolicy.new(user, project) }

  context 'for a non_member' do
    let(:user) { non_member }
    it { should_not permit(:edit) }
    it { should_not permit(:update) }
    it { should_not permit(:add_comparison) }
    it { should_not permit(:consolidate) }
  end

  context 'for leader' do
    let(:user) { leader }
    it { should permit(:edit) }
    it { should permit(:update) }
    it { should permit(:add_comparison) }
    it { should permit(:consolidate) }
  end

  context 'for consolidator' do
    let(:user) { consolidator }
    it { should permit(:edit) }
    it { should permit(:update) }
    it { should permit(:add_comparison) }
    it { should permit(:consolidate) }
  end

  context 'for contributor' do
    let(:user) { contributor }
    it { should_not permit(:edit) }
    it { should_not permit(:update) }
    it { should_not permit(:add_comparison) }
    it { should_not permit(:consolidate) }
  end

  context 'for auditor' do
    let(:user) { auditor }
    it { should_not permit(:edit) }
    it { should_not permit(:update) }
    it { should_not permit(:add_comparison) }
    it { should_not permit(:consolidate) }
  end
end
