<template>
  <div id="popWindow" class="pop-win" :class="{'show': visible}">
    <div class="cover"></div>
    <div class="pop-wrapper" :class="{'show': showPopBody}">
      <div class="pop-title">
        <i class="icon icon-arrow-left" @click="closePop"></i>
        <span class="pop-txt">{{ popTitle }}</span>
        <i class="icon icon-close" @click="closePop"></i>
      </div>
      <div class="pop-body">
        <slot name="popBody"></slot>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      showPopBody: false,
    };
  },
  watch: {
    visible(val) {
      if (val) {
        setTimeout(() => {
          this.showPopBody = true;
        }, 10);
      } else {
        setTimeout(() => {
          this.showPopBody = false;
        }, 10);
      }
    },
  },
  props: {
    visible: {
      type: Boolean,
      default: false,
    },
    popTitle: {
      type: String,
      default: '评价',
    },
  },
  methods: {
    closePop() {
      this.showPopBody = false;
      setTimeout(() => {
        this.$emit('closepop');
      }, 300);
    },
  },
};
</script>

<style lang="scss" scoped>
@import '../assets/styles/variables.scss';

.icon-arrow-left {
  width: 10px;
  height: 18px;
  background: url(../assets/images/back.png);
  background-size: 10px 18px;
}
.icon-close {
  width: 18px;
  height: 18px;
  background: url(../assets/images/close_gray.png);
  background-size: 18px 18px;
}
.pop-win {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 10;
  &.show {
    display: block;
  }
  .cover {
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, .5);
  }
  .pop-wrapper {
    position: absolute;
    bottom: -1px;
    width: 100%;
    height: 320px;
    background-color: #fff;
    border-top-left-radius: 16px;
    border-top-right-radius: 16px;
    transform: translateY(320px);
    transition: transform ease 300ms;
    &.show {
      transform: translateY(0);
    }
    .pop-title {
      padding: 0 20px;
      border-bottom: 1px solid #ccc;
      @include flex-box();
      justify-content: space-between;
      align-items: center;
      height: 70px;
    }
    .pop-txt {
      color: $color-font-43;
      font-size: $font-size-24;
    }
    .pop-body {
      padding: 30px 80px;
      text-align: center;
    }
  }
}
</style>
