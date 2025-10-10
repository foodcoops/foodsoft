import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Foodsoft",
  description: "The ordersystem for Foodcooperatives",
  base: "/foodsoft/",
  ignoreDeadLinks: true,
  locales: {
    en: { 
      label: 'English', 
      lang: 'en', 
      link: '/en/',
      themeConfig: {
        nav: [
          { text: 'Documentation', items: [ 
            {text: "Usage", link: '/en/documentation/usage' },
            {text: "Admin", link: '/en/documentation/admin' },
            {text: "Development", link: '/en/documentation/development' },
          ]},
        ],
        sidebar: {
          '/en/documentation/usage/': [
            {
              text: 'Usage',
              items: [
                { text: 'Overview', link: '/en/documentation/usage' },
                { text: 'Getting Started and Navigation', link: '/en/documentation/usage/navigation' },
                { text: 'My Profile & Order Group', link: '/en/documentation/usage/profile-ordergroup' },
                { text: 'Communication', link: '/en/documentation/usage/communication' },
                { text: 'Information & Documents', link: '/en/documentation/usage/sharedocuments' }
              ]
            }
          ],
          '/en/documentation/admin/': [
            {
              text: 'Administration',
              items: [
                { text: 'Overview', link: '/en/documentation/admin' },
                { text: 'General', link: '/en/documentation/admin/general' },
                { text: 'Suppliers & Articles', link: '/en/documentation/admin/suppliers' },
                { text: 'Orders', link: '/en/documentation/admin/orders' },
                { text: 'Storage', link: '/en/documentation/admin/storage' },
                { text: 'Finances', link: '/en/documentation/admin/finances' },
                { text: 'Users', link: '/en/documentation/admin/users' },
                { text: 'Settings', link: '/en/documentation/admin/settings' },
                { text: 'Database', link: '/en/documentation/admin/database' },
                { text: 'Demo Installations', link: '/en/documentation/admin/foodsoft-demo' },
                { text: 'Term Definitions', link: '/en/documentation/admin/terms-definitions' }
              ]
            }
          ],
          '/en/documentation/development/': [
            {
              text: 'Development',
              items: [
                { text: 'Overview', link: '/en/documentation/development' },
                { text: 'First Steps', link: '/en/documentation/development/first-steps' }
              ]
            }
          ]
        }
      }
    },
    root: { 
      label: 'Deutsch', 
      lang: 'de', 
      link: '/',
      themeConfig: {
        nav: [
          { text: 'Documentation', items: [ 
            {text: "Usage", link: '/de/documentation/usage' },
            {text: "Admin", link: '/de/documentation/admin' },
            {text: "Development", link: '/de/documentation/development' },
          ]},
        ],
        sidebar: {
          '/de/documentation/usage/': [
            {
              text: 'Anwendung',
              items: [
                { text: 'Überblick', link: '/de/documentation/usage' },
                { text: 'Starten und Navigieren', link: '/de/documentation/usage/navigation' },
                { text: 'Mein Profil & Bestellgruppe', link: '/de/documentation/usage/profile-ordergroup' },
                { text: 'Bestellungen', link: '/de/documentation/usage/order' },
                { text: 'Kommunikation', link: '/de/documentation/usage/communication' },
                { text: 'Aufgaben und Mitmachen', link: '/de/documentation/usage/tasks-cooperate' },
                { text: 'Informationen & Dokumente', link: '/de/documentation/usage/sharedocuments' }
              ]
            }
          ],
          '/de/documentation/admin/': [
            {
              text: 'Administration',
              items: [
                { text: 'Überblick', link: '/de/documentation/admin' },
                { text: 'Allgemein', link: '/de/documentation/admin/general' },
                { text: 'Lieferantinnen & Artikel', link: '/de/documentation/admin/suppliers' },
                { text: 'Bestellungen', link: '/de/documentation/admin/orders' },
                { text: 'Lager', link: '/de/documentation/admin/storage' },
                { text: 'Finanzen', link: '/de/documentation/admin/finances' },
                { text: 'Benutzerinnen', link: '/de/documentation/admin/users' },
                { text: 'Einstellungen', link: '/de/documentation/admin/settings' },
                { text: 'Datenbank', link: '/de/documentation/admin/datenbank' }
              ]
            }
          ],
          '/de/documentation/development/': [
            {
              text: 'Entwicklung',
              items: [
                { text: 'Überblick', link: '/de/documentation/development' },
                { text: 'Erste Schritte', link: '/de/documentation/development/first-steps' }
              ]
            }
          ]
        }
      }
    },
    fr: { label: 'Français', lang: 'fr', link: '/fr/' },
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    lastUpdated: true,
    editLink: {
      pattern: 'https://github.com/foodcoops/foodsoft/edit/main/doc/user/:path'
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/foodcoops/foodsoft' }
    ]
  }
})
