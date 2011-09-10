module ProfileStubs
  def setup_remembered_profile(options = {})
    request.cookies['remembered_profile_id'] = '1'
    @profile = stub_model(Profile, options)
    Profile.should_receive(:find_unowned).with('1').and_return(@profile)
  end
end
