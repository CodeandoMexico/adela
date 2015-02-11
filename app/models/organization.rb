class Organization < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged
  validates_presence_of :title

  has_many :inventories
  has_many :users
  has_many :topics
  has_many :activity_logs

  scope :with_catalog, -> { joins(:inventories).where("inventories.published = 't'").uniq }
  scope :title_sorted, -> { order("organizations.title ASC") }

  def current_inventory
    inventories.unpublished.first
  end

  def current_catalog
    inventories.published.first
  end

  def last_file_version
    inventories.date_sorted.first
  end

  def last_inventory_is_unpublished?
    current_catalog && last_file_version && (current_catalog.id != last_file_version.id)
  end

  def first_published_catalog
    inventories.published.last
  end

  def last_activity_at
    activity_logs.date_sorted.first.done_at if activity_logs.any?
  end

  def current_datasets_count
    if current_inventory.present?
      current_inventory.datasets_count
    else
      0
    end
  end

  def self.search_by(q)
    if q.present?
      where("organizations.title ~* ?", q)
    else
      self.all
    end
  end

  after_save do |record|
    CKAN::API.api_url = ENV["CKAN_API_URL"]
    org_created = CKAN::Organization.create_if_not_exists(record.title, ENV["CKAN_API_KEY"])[0]
    puts "Status organization #{org_created}"
    if org_created and CKAN::Harvest.find_by(ENV["CKAN_API_KEY"], title: record.title).empty?
      organization = org_created.id
      job_created = CKAN::Harvest.create_job(
          "http://#{ENV["DNSNAME"]}/#{record.title}/catalogo.json",
          record.title,
          "dcat_json",
          ENV["CKAN_API_KEY"],
          owner_org: organization,
          frequency: 'DAILY'
      )
      puts "Status harvest job #{job_created}"
    end
  end
end
