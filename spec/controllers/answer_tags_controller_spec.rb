describe AnswerTagsController do

  #factory objects required for "action_allowed" test cases
  let(:instructor) { build(:instructor, id: 1) }
  let(:student) { build(:student, id: 1) }

  #factory objects required for "create_edit" test cases - since creating answer tags and updating answer tags requires pre mapping of answer and tag deployment key constraints
  let(:questionnaire1) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire1, weight: 1, id: 1, type: "Criterion") }
  let(:response_map) { create(:review_response_map, id: 1, reviewed_object_id: 1) }
  let!(:response_record) { create(:response, id: 1, response_map: response_map) }
  let!(:answer) { create(:answer, question: question1, comments: "test comment", response_id: response_record.id) }
  let(:tag_prompt) { TagPrompt.create id: 1, prompt: "??", desc: "desc", control_type: "slider" }
  let(:tag_deploy) { TagPromptDeployment.create id: 1, tag_prompt: tag_prompt, question_type: "Criterion" }

  #To allow the functionality only if the accessing user is having student privileges
  #params: action

  describe '#action_allowed?' do

    context 'when user with student privilege following actions should be allowed' do
      before(:each) do
        controller.request.session[:user] = student
      end

      it 'when action index is accessed' do
        controller.params = {id: '1', action: 'index'}
        expect(controller.send(:action_allowed?)).to be true
      end

      it 'when action create_edit is accessed' do
        controller.params = {id: '1', action: 'create_edit'}
        expect(controller.send(:action_allowed?)).to be true
      end
    end

    context 'when the session is a not defined all the actions are restricted' do
      before(:each) do
        controller.request.session[:user] = nil
      end

      it 'when action index is accessed' do
        controller.params = {id: '1', action: 'index'}
        expect(controller.send(:action_allowed?)).to be false
      end

      it 'when action create_edit is accessed' do
        controller.params = {id: '1', action: 'create_edit'}
        expect(controller.send(:action_allowed?)).to be false
      end
    end
  end

  #To allow creation if not existing and simultaneously updating the new answer tag.
  #params: answer_id (answer id mapping to which tag is being created)
  #params: tag_prompt_deployment_id (tag_prompt id mapping to which tag is being created)
  #params: value (new value to be updated)

  describe '#create_edit' do
    context 'when student tries to create or update the answer tags' do
      before(:each) do
        controller.request.session[:user] = student
      end

      it 'add entry if not existing and update the old value by new value provided as param' do
        params = {answer_id: answer.id,tag_prompt_deployment_id: tag_deploy.id,value: 0}
        post :create_edit, params, session
        expect(response).to have_http_status(200)
      end

      it 'restricts updating answer tag by student if no mapping is found related to any answer for that tag (foreign key constraint)' do
        params = {answer_id: nil,tag_prompt_deployment_id: tag_deploy.id,value: 0}
        expect {
          post :create_edit, params, session
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'restricts updating answer tag by student if no mapping is found related to any tag_prompt_deployment for that tag (foreign key constraint)' do
        params = {answer_id: answer.id,tag_prompt_deployment_id: nil,value: 0}
        expect {
          post :create_edit, params, session
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'restricts updating answer tag by student if no updated value is provided for the answer tag' do
        params = {answer_id: answer.id,tag_prompt_deployment_id: tag_deploy.id,value: nil}
        expect {
          post :create_edit, params, session
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

    end
  end

end
