class Spree::Issue < ActiveRecord::Base
  belongs_to :magazine, class_name: "Spree::Product"
  belongs_to :magazine_issue, class_name: "Spree::Product"
  has_many :shipped_issues

  delegate :subscriptions, to: :magazine

  validates :name,
            presence: true,
            unless: "magazine_issue.present?"

  scope :shipped, -> { where("shipped_at IS NOT NULL") }
  scope :unshipped, -> { where("shipped_at IS NULL") }

  scope :shipped, -> { with_state(:shipped) }
  scope :unshipped, -> { with_state(:unshipped) }
  
  state_machine initial: :unshipped do
    event :ship do
      transition :unshipped => :ship_pending
    end
    
    event :confirm_ship_complete do
      transition :ship_pending => :shipped
    end
    
    event :unship do
      transition :shipped => :unship_pending      
    end

    event :confirm_unship_complete do
      transition :unship_pending => :unshipped
    end
    
    after_transition :unshipped => :ship_pending do |issue|
      issue.delay.deliver_issues! # TODO make the delay dependent on preferences
    end

    before_transition :ship_pending => :shipped do |issue|
      issue.update_attribute(:shipped_at, Time.now)
    end
    
    after_transition :shipped => :unship_pending do |issue|
      issue.delay.undeliver_issues! # TODO make the delay dependent on preferences
    end
    
    before_transition :unship_pending => :unshipped do |issue|
      issue.update_attribute(:shipped_at, nil)
    end
  end
  
  def name
    magazine_issue.present? ? magazine_issue.name : read_attribute(:name)
  end

  def magazine
    # override getter method to include deleted products, as per https://github.com/radar/paranoia
    Spree::Product.unscoped { super }
  end
  
  def magazine_issue
    # override getter method to include deleted products, as per https://github.com/radar/paranoia
    Spree::Product.unscoped { super }
  end
  
  def to_csv
    if shipped_issues.present?
      shipped_issues.csv_string
    else
      Spree::Subscription.where(id: magazine.subscriptions.eligible_for_shipping_issue(self).collect{|s| s.id}).csv_string
    end
  end
  
  private
  
  def deliver_issues!
    self.subscriptions.eligible_for_shipping_issue(self).each{ |s| s.ship!(self) }
    self.confirm_ship_complete
  end
  
  def undeliver_issues!
    Spree::Subscription.where(id: self.shipped_issues.pluck(:subscription_id)).each{ |s| s.unship!(self) }
    self.confirm_unship_complete
  end

end
