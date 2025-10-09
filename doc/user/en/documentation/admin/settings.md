---
title: Settings
description: Explanation of global and administrative Foodsoft settings
published: true
date: 2021-10-07T18:34:41.218Z
tags: 
editor: markdown
dateCreated: 2021-04-21T00:20:52.701Z
---

# Foodsoft Settings

This section covers the global administrative settings that control how Foodsoft operates for your food cooperative.

## General Settings

### Food Cooperative Information

- **Name**: The name of your food cooperative as it appears throughout Foodsoft
- **Address**: Physical address of the food cooperative
- **Contact Information**: Phone, email, and website details
- **Homepage**: URL to your food cooperative's website

### Regional Settings

- **Language**: Default language for the interface
- **Currency**: Currency symbol and formatting
- **Time Zone**: Local time zone for scheduling and timestamps
- **Date Format**: How dates are displayed throughout the system

## User and Group Settings

### Registration and Invitations

- **Allow self-registration**: Whether new users can register themselves
- **Require invitation**: Whether new users need an invitation to join
- **Email verification**: Require email verification for new accounts
- **Default permissions**: Standard permission level for new users

### Order Groups

- **Minimum members per group**: Required number of members in an order group
- **Allow single-member groups**: Whether individual users can form their own order group
- **Group naming conventions**: Rules for order group names

## Financial Settings

### Account Management

- **Use financial features**: Enable/disable the financial management system
- **Minimum account balance**: Lowest allowed account balance for ordering
- **Account transaction classes**: Configure different types of transactions
- **Payment reference codes**: Enable automatic payment processing

### Invoicing and Payments

- **Tax handling**: How VAT/taxes are calculated and displayed
- **Invoice numbering**: Automatic invoice number generation
- **Payment terms**: Default payment terms for suppliers
- **Bank account integration**: Connect to banking systems for automatic processing

## Ordering Settings

### Order Management

- **Default order duration**: How long orders stay open by default
- **Minimum order quantities**: Global minimum order requirements
- **Tolerance handling**: How tolerance quantities are managed
- **Order confirmation**: Automatic confirmation settings

### Pickup and Delivery

- **Default pickup days**: Standard days for order pickup
- **Pickup locations**: Available pickup locations
- **Delivery scheduling**: Automatic delivery date calculation
- **Notification settings**: When and how to notify members about orders

## Communication Settings

### Messaging

- **Enable internal messaging**: Allow messages between members
- **Message retention**: How long to keep messages
- **Email notifications**: Which events trigger email notifications
- **Message groups**: Enable targeted group messaging

### Notifications

- **Order reminders**: Automatic reminders about open orders
- **Account balance warnings**: Notify when balance is low
- **Task assignments**: Notifications for assigned tasks
- **System announcements**: Important system-wide messages

## Task and Participation Settings

### Task Management

- **Enable task system**: Allow task assignment and tracking
- **Apple point system**: Enable the participation tracking system
- **Required participation**: Minimum participation requirements for ordering
- **Task categories**: Different types of tasks available

### Apple Points

- **Calculation method**: How apple points are calculated
- **Minimum points for ordering**: Required points to place orders
- **Point decay**: How points decrease over time
- **Exemptions**: Groups exempt from point requirements

## Plugin and Feature Settings

### Optional Features

- **Wiki system**: Enable the internal wiki
- **Document management**: File sharing and document storage
- **Polls and surveys**: Member voting and feedback tools
- **Links menu**: Custom links in the navigation

### External Integrations

- **Supplier connections**: Direct integration with supplier systems
- **Accounting software**: Export data to external accounting tools
- **Communication platforms**: Integration with forums or chat systems
- **Analytics**: Usage tracking and reporting tools

## Security Settings

### Access Control

- **Session timeout**: How long users stay logged in
- **Password requirements**: Minimum password complexity
- **Two-factor authentication**: Additional security measures
- **IP restrictions**: Limit access from specific locations

### Data Protection

- **Privacy settings**: Control what information is visible to members
- **Data retention**: How long to keep different types of data
- **Backup settings**: Automatic backup configuration
- **Audit logging**: Track administrative actions

## System Maintenance

### Performance

- **Cache settings**: Improve system performance
- **Database optimization**: Automatic maintenance tasks
- **File cleanup**: Remove old temporary files
- **Log rotation**: Manage system log files

### Updates and Monitoring

- **Update notifications**: Alerts about available updates
- **System monitoring**: Track system health and performance
- **Error reporting**: Automatic error notification
- **Maintenance mode**: Temporarily disable access for updates

## Configuration Best Practices

### Initial Setup

1. Configure basic food cooperative information
2. Set up financial settings if using accounting features
3. Configure user registration and permissions
4. Set up communication preferences
5. Test all settings with a small group before full deployment

### Ongoing Management

- Regularly review and update settings as needs change
- Monitor system performance and adjust settings accordingly
- Keep security settings up to date
- Document any custom configurations for future reference

### Troubleshooting

- Check logs for configuration-related errors
- Test settings in a development environment before applying to production
- Maintain backups before making significant configuration changes
- Document all changes for audit and rollback purposes

> Settings may vary depending on your Foodsoft version and installed plugins. Always test configuration changes in a safe environment first.
{.is-warning}

> Some advanced settings may require database access or system administrator privileges to modify.
{.is-info}