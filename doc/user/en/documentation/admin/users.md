---
title: Users
description: Management of all members, their Foodsoft accounts and order groups
published: true
date: 2021-11-26T11:06:26.697Z
tags: 
editor: markdown
dateCreated: 2021-04-20T19:57:55.363Z
---

# User Management

This section covers the management of users, order groups, workgroups, and message groups in Foodsoft.

## Users

Individual Foodsoft accounts for members of the food cooperative.

### Creating Users

Administration \> Users \> New User

Required information:
- First and last name
- Email address (used for login)
- Initial password
- Order group assignment

### User Permissions

Users can be assigned different permission levels:

- **Standard**: Basic ordering permissions
  - Can place and modify orders
  - Can view their own account information
  - Can participate in polls and tasks

- **Orders**: Can manage orders and suppliers
  - All standard permissions
  - Can create and manage orders
  - Can manage supplier information and articles
  - Can receive deliveries and adjust orders

- **Finances**: Can manage financial transactions and settle orders
  - All standard permissions  
  - Can manage member account balances
  - Can create and manage invoices
  - Can settle orders and process payments
  - Can access financial reports

- **Admin**: Full administrative access
  - All permissions above
  - Can manage users and groups
  - Can modify system settings
  - Can access database functions

### Editing Users

Administration \> Users \> Click on user name

You can modify:
- Personal information
- Email address
- Password (reset)
- Permission levels
- Order group membership
- Active/inactive status

## Order Groups

Groups of users who order together and share a common account balance.

### Creating Order Groups

Administration \> Order Groups \> New Order Group

Required information:
- Group name
- Contact person
- Initial account balance (if using financial features)

### Order Group Settings

- **Account balance**: Current credit available for orders
- **Members**: Users who belong to this group
- **Contact information**: Primary contact details
- **Custom fields**: Additional information (if configured)

## Workgroups

Groups responsible for specific tasks within the food cooperative.

### Creating Workgroups

Administration \> Workgroups \> New Workgroup

Workgroups can be assigned specific permissions and responsibilities:
- Order management
- Financial administration
- Supplier relations
- Member coordination

### Workgroup Permissions

Workgroups can be granted specific permissions that apply to all their members:
- Orders: Manage ordering process
- Finances: Handle financial transactions
- Suppliers: Manage supplier relationships
- Admin: Administrative functions

## Message Groups

Groups for targeted communication within the food cooperative.

### Creating Message Groups

Administration \> Message Groups \> New Message Group

Message groups allow:
- Targeted communication to specific member groups
- Self-service joining/leaving by members
- Organized information distribution

### Message Group Types

- **Open**: Members can join and leave freely
- **Restricted**: Only administrators can add/remove members
- **Automatic**: Membership based on other criteria (e.g., all order group contacts)

## User Import and Export

### Importing Users

For larger food cooperatives, users can be imported via CSV files:

1. Prepare CSV file with required columns
2. Administration \> Users \> Import
3. Map CSV columns to Foodsoft fields
4. Review and confirm import

### Exporting User Data

User information can be exported for:
- Backup purposes
- External communication tools
- Membership management

## Inactive Users and Data Retention

### Deactivating Users

Users who leave the food cooperative should be deactivated rather than deleted to preserve:
- Order history
- Financial transaction records
- System integrity

### Data Privacy

Foodsoft respects data privacy requirements:
- Users can request their data
- Personal information can be anonymized
- Account deletion follows configured retention policies

## Best Practices

### User Management

- Use descriptive order group names
- Regularly review and update permissions
- Maintain accurate contact information
- Document role assignments

### Security

- Encourage strong passwords
- Regularly review admin permissions
- Monitor user activity for unusual patterns
- Keep user information up to date

### Communication

- Use message groups for targeted communication
- Maintain clear workgroup responsibilities
- Document procedures for new administrators
- Provide user training materials

> Detailed user management procedures may vary depending on your food cooperative's specific needs and local regulations.
{.is-info}