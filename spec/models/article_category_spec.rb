require_relative '../spec_helper'

describe ArticleCategory do
  let(:article) { create(:article) }
  let(:article_category) { create(:article_category, article_versions: [article.latest_article_version]) }

  it 'cannot be destroyed if there are associated undeleted articles' do
    expect { article_category.destroy! }.to raise_error(RuntimeError)
    expect(article_category).not_to be_destroyed
  end

  it 'can be destroyed unless there are associated undeleted articles' do
    article.mark_as_deleted
    article_category.destroy!
    expect(article_category).to be_destroyed
  end
end
