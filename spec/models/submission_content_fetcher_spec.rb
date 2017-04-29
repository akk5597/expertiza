require 'rails_helper'

describe "SubmissionContentFetcher" do

  it "cannot be instantiated" do
    expect(SubmissionContentFetcher.new).to raise_error(NoMethodError)
  end

  it "creates the correct factory for wiki documentation" do
    url = "http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Spring_2016/E1738_Integrate_Simicheck_Web_Service"
    fetcher = SubmissionContentFetcher.DocFactory(url)
    expect(fetcher).to be_instance_of(WebsiteFetcher)
    expect(fetcher).to have_attributes(:url => url)
  end

  it "creates the correct factory for google docs edit URL documentation" do
    url = "https://docs.google.com/document/d/1-waDJtPB8VGLyubb40-X951PF9R3jdhm6Kb4ga__S0E/edit"
    fetcher = SubmissionContentFetcher.DocFactory(url)
    expect(fetcher).to be_instance_of(GoogleDocFetcher)
    expect(fetcher).to have_attributes(:url => url)
  end

  it "creates the correct factory for google docs drive URL documentation" do
    url = "https://drive.google.com/open?id=1Ngds9Fr4vas8n0cA-uvZDOU7VMarMfGytbC9VLc0IYI"
    fetcher = SubmissionContentFetcher.DocFactory(url)
    expect(fetcher).to be_instance_of(GoogleDocFetcher)
    expect(fetcher).to have_attributes(:url => url)
  end

  it "creates the correct factory for github pull request code" do
    url = "https://github.com/totallybradical/simicheck-expertiza-sandbox/pull/3"
    fetcher = SubmissionContentFetcher.CodeFactory(url)
    expect(fetcher).to be_instance_of(GithubPullRequestFetcher)
    expect(fetcher).to have_attributes(:url => url)
  end

  it "does not create for a bogus URL" do
    expect( SubmissionContentFetcher.DocFactory("") ).to be_nil
    expect( SubmissionContentFetcher.CodeFactory("") ).to be_nil
    expect( SubmissionContentFetcher.DocFactory("bogus URL") ).to be_nil
    expect( SubmissionContentFetcher.CodeFactory("bogus URL") ).to be_nil
  end

end
