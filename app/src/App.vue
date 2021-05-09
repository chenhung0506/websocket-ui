<template>
  <div id="app">
    <router-view/>
  </div>
</template>

<script>
import Chat from './components/Chat';

export default {
  name: 'App',
  components: {
    Chat,
  },
 data() {
    return {
      location: '',
    };
  },
  mounted() {
    this.init();
  },
  methods: {
    getQueryString(name) {
      // console.log(name);
      const getReg = `(^|&)${name}=([^&]*)(&|$)`;
      let reg = new RegExp(getReg, 'i');
      let r = window.location.search.substr(1).match(reg);
      let context = '';
      if (r != null) {
        context = r[2];
      }
      reg = null;
      r = null;
      return context == null || context === '' || context === 'undefined' ? '' : context;
    },
    init() {
      this.location = this.getQueryString('location');
      if (this.location === 'cn') {
        this.$i18n.locale = 'zh-cn';
        localStorage.setItem('locale', 'zh-cn');
        this.$el.style.fontFamily = 'FZLTHJW--GB1-0,FZLTHJW--GB1';
      } else if (this.location === 'en') {
        this.$i18n.locale = 'zh-en';
        localStorage.setItem('locale', 'zh-en');
        this.$el.style.fontFamily = 'ContinentalStagSans-Book,ContinentalStagSans';
      } else {
        this.$i18n.locale = 'zh-tw';
        localStorage.setItem('locale', 'zh-tw');
        this.$el.style.fontFamily = 'FZLTHJW--GB1-0,FZLTHJW--GB1';
      }
      document.getElementsByTagName('title')[0].innerText = this.$t('common.title');
    },
  },
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
