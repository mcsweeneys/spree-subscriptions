class AddStateToSpreeIssues < ActiveRecord::Migration
  def up
    add_column :spree_issues, :state, :string
    Spree::Issue.where(shipped_at: nil).update_all(state: :unshipped)
    Spree::Issue.where.not(shipped_at: nil).update_all(state: :shipped)
  end

  def down
    remove_column :spree_issues, :state, :string
  end
end
