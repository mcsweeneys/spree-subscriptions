Deface::Override.new(virtual_path: "spree/products/_cart_form",
  name: "use_subscribe_locale_instead_of_add_to_cart",
  replace: "erb[loud]:contains(\"Spree.t(:add_to_cart)\")",
  text: "<%= @product.subscribable? ? (spree_current_user && spree_current_user.subscriptions.where(magazine: @product).present? ? Spree.t(:renew_call_to_action) : Spree.t(:subscribe_call_to_action)) : Spree.t(:add_to_cart) %>"
  )

Deface::Override.new(virtual_path: "spree/products/_cart_form",
  name: "add_subscription_info_to_add_to_cart",
  insert_bottom: "div.add-to-cart",
  text: "
  <% if @product.subscribable? && spree_current_user && spree_current_user.subscriptions.where(magazine: @product).present? %>
    <% user_sub = spree_current_user.subscriptions.where(magazine: @product).order(:created_at).order(:remaining_issues).last %>
    <div class='subscription_status'>
      <% if user_sub.remaining_issues > 0 %>
        <%= user_sub.remaining_issues.to_s + ' ' + 'Issue'.pluralize(user_sub.remaining_issues) + ' Remaining' %>
      <% elsif user_sub.shipped_issues.present? %>
        <%= 'Expired on ' + user_sub.shipped_issues.last.issue.shipped_at.strftime('%B %e, %Y') %>
      <% end %>
    </div>
  <% end %>"
  )

Deface::Override.new(virtual_path: "spree/products/_cart_form",
  name: "hide_number_field_for_subscribable_products",
  replace: "erb[loud]:contains(\"number_field_tag\")",
  partial: "spree/products/cart_form_number_field"
  )
