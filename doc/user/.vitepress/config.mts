import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Foodsoft",
  description: "The ordersystem for Foodcooperatives",
  locales: {
    en: { label: 'English', lang: 'en', link: '/en/' },
    root: { label: 'Deutsch', lang: 'de', link: '/' },
    fr: { label: 'Français', lang: 'fr', link: '/fr/' },
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
        { text: 'Documentation', items: [ 
          {text: "Usage", link: '/de/documentation/usage' },
          {text: "Admin", link: '/de/documentation/admin' },
        ]},
    ],
    lastUpdated: true,
    editLink: {
      pattern: 'https://github.com/foodcoops/foodsoft/edit/main/doc/user/:path'
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/foodcoops/foodsoft' }
    ]
  }
})
