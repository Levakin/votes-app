module.exports = {
  /*
	** Headers of the page
	*/
  head: {
    title: 'votes-app',
    meta: [
      { charset: 'utf-8' },
      {
        name: 'viewport',
        content: 'width=device-width, initial-scale=1,' + 'shrink-to-fit=no'
      },
      {
        hid: 'description',
        name: 'description',
        content: 'Nuxt.js and web3 votes project'
      }
    ],
    link: [{ rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }]
  },
  /*
	** Customize the progress bar color
	*/
  loading: { color: '#3B8070' },
  /*
	** Build configuration
	*/
  build: {
    vendor: ['web3'],
    /*
		** Run ESLint on save
		*/
    extend(config, ctx) {
      // Run ESLint on save
      if (ctx.isDev && ctx.isClient) {
        config.module.rules.push({
          enforce: 'pre',
          test: /\.(js|vue)$/,
          loader: 'eslint-loader',
          exclude: /(node_modules)/
        })
      }
    }
  },
  modules: [
    'bootstrap-vue/nuxt'

    // Or if you have custom bootstrap CSS...
    // ['bootstrap-vue/nuxt', { css: false }]
  ],
  srcDir: 'src/',
  rootDir: './'
}
