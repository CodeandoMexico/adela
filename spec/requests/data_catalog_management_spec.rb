require 'spec_helper'

feature "data catalog management" do
  
  background do
    @organization = FactoryGirl.create(:organization)
    @empty_response = {}
  end

  scenario "can consume published catalog data" do
    given_there_is_a_catalog_published 10.days.ago
    get "/#{@organization.slug}/catalogo.json"
    gets_catalog_json_data_in response
  end

  scenario "can't consume unpublished catalog data" do
    given_there_is_an_inventary_by("CONEVAL", "unpublished")
    get "/coneval/catalogo.json"
    gets_empty response
  end

  scenario "can see all the catalogs available through the api" do
    given_there_is_an_inventary_by("CONEVAL", "published")
    given_there_is_an_inventary_by("Presidencia", "published")
    given_there_is_an_inventary_by("Hacienda", "unpublished")
    get "/api/v1/organizations/catalogs.json"
    gets_all_catalogs_urls_in response
  end

  scenario "can consume catalog data even with inventory empty fields" do
    inventory_file = File.new("#{Rails.root}/spec/fixtures/files/inventory_with_blanks.csv")
    inventory =  FactoryGirl.create(:published_inventory, :publish_date => 1.day.ago, :csv_file => inventory_file)
    inventory.update_attributes(:organization_id => @organization.id)

    get "/hacienda/catalogo.json"

    json_response = JSON.parse(response.body)
    json_response["dataset"].size == 2
    json_response["dataset"][0]["keywords"].should be_nil
  end

  scenario "catalog will have correct DCAT key names" do
    inventory_file = File.new("#{Rails.root}/spec/fixtures/files/conflicting_inventory_issue-106.csv")
    inventory =  FactoryGirl.create(:published_inventory, :publish_date => 1.day.ago, :csv_file => inventory_file)
    inventory.update_attributes(:organization_id => @organization.id)

    dcat_keys = %w{ title description homepage issued modified language license dataset }
    dcat_dataset_keys = %w{ title description modified contactPoint identifier accessLevel accessLevelComment spatial language publisher keyword distribution }
    dcat_distribution_keys = %w{ title description license downloadURL mediaType format byteSize temporal spatial accrualPeriodicity }

    get "/hacienda/catalogo.json"
    json_response = JSON.parse(response.body)
    json_response.keys.should eq(dcat_keys)
    json_response["dataset"].last.keys.should eq(dcat_dataset_keys)
    json_response["dataset"].last["distribution"].last.keys.should eq(dcat_distribution_keys)

    # Makes damn sure that no foreign attributes are set in the model
    # See: https://github.com/mxabierto/adela/issues/106
    dataset = ActiveSupport::JSON.decode(inventory.datasets.last.to_json)
    dataset.keys.include?("erick.maldonado@indesol.gob.mx").should eq(false)
  end

  def given_there_is_a_catalog_published(days_ago)
    @inventory = FactoryGirl.create(:published_inventory, :publish_date => days_ago)
    @inventory.update_attributes(:organization_id => @organization.id)
  end

  def gets_catalog_json_data_in(response)
    json_response = JSON.parse(response.body)
    json_response["title"].should == "Catálogo de datos abiertos de #{@organization.title}"
    json_response["dataset"][0]["distribution"].size == 3
    json_response["dataset"][1]["distribution"].size == 4
    json_response["dataset"][1]["identifier"] == "indice-rezago-social"
  end

  def gets_empty(response)
    json_response = JSON.parse(response.body)
    json_response.should == @empty_response
  end

  def given_there_is_an_inventary_by(organization_title, status)
    organization = FactoryGirl.create(:organization, :title => organization_title)
    case status
    when "published"
      inventory = FactoryGirl.create(:published_inventory)
    when "unpublished"
      inventory = FactoryGirl.create(:inventory)
    end
    inventory.update_attributes(:organization_id => organization.id)
  end

  def gets_all_catalogs_urls_in(response)
    json_response = JSON.parse(response.body)
    json_response.size.should == 2
  end
end
