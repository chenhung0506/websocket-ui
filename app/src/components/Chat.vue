<template>
  <div class="robot-chat-wrap" :class="platform === 'web' ? 'robot-chat-web' : ''">
    <div class="deskConHeaderXm">
      <!-- <a href="javascript::" class="deskHeaderBack"></a> -->
          <div class="connorTitle">
            <p>{{ titleTime }}</p>
          </div>
      <!-- <a href="javascript::" class="deskHeaderClose"></a> -->
    </div>
    <section class="note-wrap" :class="{'close': !notifyClose}" style="display:none">
      <span class="note-title">{{ $t('common.notice') }}：</span>
      <!-- <span class="note-body">{{ announcementAns }}</span> -->
      <i class="icon icon-close" @click="notifyClose = false"></i>
    </section>
    <section class="chat-wrap" id="chatBox" ref="chatBox">
      <template v-for="(val, index) in chatList">
      <div v-if="val.role === 'robot'" class="robot chat-box" :key="index">
        <div class="chat-content" v-if="val.type === 'multiple'">
          <div class="chat-body">
            <div :class="idx === 0 ? 'multi-first' : 'multi-recom'"
            v-for="(item, idx) in val.data" :key="idx">
            <template v-if="item.subType !== 'image'">
              <div class="chat-body-txt" v-if="item.subType === 'text' || item.subType === 'human'"
              v-html="item.value === 'backfill' ? backfill : item.value">
              </div>
              <div class="rq-box"
              v-if="item.subType === 'guslist' || item.subType === 'relatelist'">
                <span class="relateTit"
                v-html="item.relateVal ? item.relateVal : item.value"></span>
                <ul>
                  <li v-for="(liItem, i) in item.data" :key="i"
                  @click="sendUserText(liItem, true, i+1, false)">
                    {{ liItem }}
                  </li>
                  <li v-if="item.nextNum > 0" @click="sendUserText('下一页', true, true)">下一页</li>
                </ul>
                <span v-html="item.relateVal ? item.relateVal : item.valueTmp"></span>
              </div>
            </template>
            <template v-else>
              <div class="img-box">
                <img :src="item.value" preview="1" preview-text="" />
              </div>
            </template>
            </div>
          </div>
        </div>
        <div class="chat-content" v-else>
          <div class="chat-body"
            :class="{'chat-have-faq' : val.subType === 'guslist' || val.subType === 'relatelist'}"
            v-if="val.subType !== 'image' && !val.isHello">
            <div class="chat-body-txt" v-if="val.subType === 'text' || val.subType === 'human'"
            v-html="val.value === 'backfill' ? backfill : val.value">
            </div>
            <div class="chat-body-txt"
            v-show="val.relateVal || val.value "
            v-if="val.subType === 'guslist' || val.subType === 'relatelist'">
              <span v-html="val.relateVal ? val.relateVal : val.value"></span>
            </div>
            <ul class="faq-list">
              <li v-for="(item, i) in val.data" :key="i"
              @click="sendUserText(item, true, i+1, false)">
                <span>{{ item }}</span>
              </li>
            </ul>
          </div>
        </div>
        <div class="chat-body-txt" v-if="feedback">
          <ul class="statis-faction">
            <li @click="sendFeedBack('helpful', val)" class="chat-body-txt-link solve"
            :class="(val.feedback && val.feedback === 'helpful') ? 'selected' : ''"></li>
            <li @click="sendFeedBack('unhelpful', val)" class="chat-body-txt-link unsolve"
            :class="(val.feedback && val.feedback === 'unhelpful') ? 'selected' : ''"></li>
            <li class="chat-body-txt-link"
              :style="val.feedBackLiStyle">
              <input :style="val.feedBackInputStyle" v-model="val.feedBackMessage">
            </li>
            <li class="chat-body-txt-link"
              @click="openFeedbackInput(val)"
              :class="val.feedbackMessageImg ? 'feedback-message-img': ''"
              :style="val.submitButton">
              {{val.feedbackMessageImg?'':'傳送'}}
            </li>
          </ul>
        </div>
      <div class="chat-time left" v-if="val.isShow">
        {{showTimes(val, index).time}}
      </div>
      </div>


      <div v-else-if="val.role === 'user'" class="user chat-box" :key="index">
        <div class="chat-content">
        <div class="chat-body">
          <div class="chat-body-txt" style="color:#F5F5F5;">{{ val.value }}</div>
        </div>
        <i class="icon icon-user" style="display:none;"><img :src="headImg"/></i>
        </div>
        <div class="chat-time right" v-if="val.isShow">
          {{showTimes(val, index).time}}
        </div>
      </div>
      </template>
    </section>
    <section class="input-wrap">
      <!-- <recommend-swiper :list="recommendList" @sendmsg="sendUserText"></recommend-swiper>
      <recommend-swiper :list="recommendList2" @sendmsg="sendUserText"></recommend-swiper> -->
      <!-- @blur="inputBlur" @focus="inputFocus" -->
      <div class="input-wrapper">
        <div class="left">
          <input id="userInput" v-if="platform === 'web'"
          :placeholder="$t('common.input_placeholder')"
          @focus="inputFocusFun"
          @blur="inputBlurFun"
          v-model.trim="userQ"/>
        </div>
        <div class="right">
          <button class="btn-submit"
          :class="canSend ? 'icon-submit': 'icon-submit-disabled'"
          :disabled="canSend"
          @click="sendText">
          <li style="list-style:none;">發送</li>
          </button>
        </div>
      </div>
    </section>
    <pop-win
    ref="popWin"
    :visible="showRate"
    @closepop="closePop">
      <div slot="popBody">
        <div class="score-title">{{ $t('common.satisfaction') }}</div>
        <button class="btn-submit-rate" @click="submitRate">{{ $t('common.submit_eval') }}</button>
      </div>
    </pop-win>
  </div>
</template>

<script>
import { uuid } from 'vue-uuid';
import PopWin from './Pop';

/* eslint-disable */
export default {
  name: 'robot-chat',
  data() {
    return {
      userId:'',
      titleTime: '',
      sessionId: '',
      scenario: '',
      uuid: '',
      feedback: false,
      axios: require('axios'),
      pageData: '',
      isOpenLeft: false,
      isOpenRight: false,
      isscroll: false,
      isexpand: false,
      notifyClose: true,
      chatUrl: '/xuhui/chat-room/v1/openapi',
      userQ: '',
      chatList: [],
      announcementTxt: '公告栏',
      announcementAns: '',
      recommendQ: '滑动点击',
      recommendList: [],
      recommendList2: [],
      showRate: false,
      rate: null,
      iconClasses: ['icon-rate-star', 'icon-rate-star', 'icon-rate-star'],
      webSocket: null,
      senderId: null,
      mess: {},
      data: null,
      location: '',
      sqList: [],
      platform: 'web',
      isSetHello: false,
      canSend: true,
      hadSolve: '',
      headImg: require('../assets/images/head_user.png'),
      winHeight: 0,
      scrollY: 0,
      inputTimer: null,
      timer: {},
      webSocketTimer: {},
      webSocketIsInit: false,
      helloMsg: {"data":["明日天氣預報","一週天氣","留言"],"subType":"relatelist","type":"text","value":"歡迎使用以下功能"},
    };
  },
  components: {
    PopWin,
  },
  created() {
    this.getInit();
  },
  mounted() {
    this.isscroll = true;
    const that = this;
    document.body.addEventListener('touchmove', () => {
      document.getElementById('userInput').blur();
    });
    document.getElementById('app').addEventListener('click', (e) => {
      e.stopPropagation();
      if (e.target.className !== 'bubble-main'
      && e.target.id !== 'iconBubble'
      && e.target.className !== 'bubble-small'
      && that.isexpand) {
        that.isexpand = false;
      }
    });
    document.addEventListener('keyup', (event) => {
      if (event.key === 'Enter') {
        that.sendText();
      }
    });
    window.onresize = this.onresize;
    this.winHeight = window.innerHeight;
  },
  beforeDestroy() {
    this.onbeforeunload();
  },
  watch: {
    chatList: {
      handler() {
        // this.$previewRefresh();
      },
      deep: true,
    },
    userQ() {
      if (this.userQ.trim() === '') {
        this.canSend = true;
      } else {
        this.canSend = false;
      }
    },
  },
  methods: {
    getDomain() {
      // return '192.168.3.155';
      // return window.location.host;
      // return 'localhost:3002';
      return 'localhost:80';
    },
    openFeedbackInput(val) {
      if (val.feedbackMessageImg === true) {
        val.feedbackMessageImg = false;
        val.feedBackLiStyle = {"content": "", "display":"inline-block", "width": "183px", "height": "30px", "margin":"0px 0px 0 6px"},
        val.feedBackInputStyle = {"display":"inline-block", "width": "160px", "height": "25px" ,"padding": "0 0 0 0","margin": "0 3px 0 0"};
      } else {
        this.sendFeedBack('', val);
        val.feedbackMessageImg = true,
        val.feedBackLiStyle = {"display":"none"},
        val.feedBackInputStyle = {"display":"none"}
      }
    },
    // getImgUrl(imageName) {
    //   // var images = require.context('../assets/images/tutorial/', false, /\.png$/)
    //   var images = require.context('../assets/images/tutorial/', false)
    //   return images('./' + imageName )
    // },
    urlSearchParams(name) {
      const uri = '&' + window.location.search.substring(1);
      var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(uri);
      if (results == null){
        return null;
      }
      else {
        return decodeURI(results[1]) || 0;
      }
    },
    intervalWebsocketConnect() {
        if (this.webSocket.readyState === 1) {
            this.webSocketIsInit=true
            this.stopInterval('websocket connect', this.webSocketTimer)
        }
    },
    stopInterval(interName,timer) {
        clearInterval(timer)
        this.log('clear interval success:', interName)
    },
    getInit() {
      const protocol = document.location.protocol;
      this.senderId = 'test';
      this.isDebug = this.urlSearchParams("debug") === "true" ? true : false;
      this.userId = this.urlSearchParams("userId");
      this.sessionId = this.urlSearchParams("session_id");
      if (this.sessionId ===null ) {
        this.sessionId = uuid.v1()
      }
      if (this.userId === null) {
        this.userId = this.sessionId;
        console.log('use session be userId')
      }
      console.log('userId:', this.userId);
      if (this.senderId === '' || this.senderId === null) {
        this.senderId = this.getCookie('continental_name');
        if (this.senderId === null) {
          const rand = Math.floor(1000 + Math.random() * 9000);
          const timestamp = new Date().getTime();
          this.senderId = `continental${timestamp}${rand}`;
          this.setCookie('continental_name', this.senderId);
          console.log("senderId:",this.senderId);
        }
      }
      const platForm = this.getQueryString('platform');
      if (platForm === undefined || platForm === '' || platForm === null) {
        this.platform = 'web';
      } else {
        this.platform = platForm;
      }
      console.log('start init webSocket',new Date().toLocaleTimeString())
      this.initWebSocket(this.senderId).then((response)=>{
        if (!response) {
          console.log('Not support websocket')
          alert('Not support websocket');
          return;
        } else {
          console.log('webSocket.readyState:',this.webSocket.readyState, new Date().toLocaleTimeString());
        }
      })
      console.log(this.helloMsg)
      this.handleProcessAnswer(JSON.stringify(this.helloMsg));

      const domain = this.getDomain();
      const params = {
        domain: this.getQueryString('location') || 'www.continental-tires.cn',
      };
      const qUrl = `${protocol}//${domain}/chat-room/message/showFaq`;


    },
    sendText() {
      if (this.userQ.length <= 0) {
        return;
      }
      const message = this.userQ;
      this.sendUserText(message, true);
    },
    statisFaction(number, data) {
      if (data.ifStatis === 'none') {
        const protocol = document.location.protocol;
        const domain = this.getDomain();
        if (number === '4') {
          data.ifStatis = 'yes';
        } else {
          data.ifStatis = 'no';
        }
        const params = {
          userId: data.data[0].userId,
          sessionId: data.data[0].sessionId,
          num: number,
          appId: data.data[0].appId,
        };
        const qUrl = `${protocol}//${domain}/chat-room/message/statisFaction`;
        this.$reqPost(qUrl, params).then((res) => {
          if (res.data === 'ok') {
          }
        }).catch(() => {});
      }
    },
    sendUserText(input, append, m = 0, sqTF = false) {
      let val = input;
      if (m > 0) {
        val = input.replace(`${m}.`, '');
      }
      if (!sqTF && val !== '下一页' && val !== 'next') {
        this.sqList = [];
        this.sqList.length = 0;
      }

      // if (this.webSocket === null || this.webSocket.readyState !== 1) {
      //   if(!(this.initWebSocket(this.senderId))) {
      //     alert('Not support websocket')
      //     return;
      //   }
      // }

      if (append) {
        const userTxtObj = {
          subType: 'text',
          type: 'text',
          value: val,
        };
        this.appendChat(userTxtObj);
      }

      this.mess.userList = [];

      this.mess.mess = val;
      if (this.location.length > 0) {
        this.mess.domain = this.location;
      } else {
        this.mess.domain = 'websocket.linch.ml';
      }
      this.mess.userId = this.userId;
      this.mess.sessionId = this.sessionId;
      this.uuid = uuid.v1();
      this.mess.uuid = this.uuid;
      const strMess = JSON.stringify(this.mess);
      this.log("strMess", strMess);
      if (val !== '' && this.webSocket.readyState === 1) {
        this.webSocket.send(strMess);
      }
      this.userQ = '';
    },
    handleProcessAnswer(data) {
      console.log(data.length)
      if (data && data.length > 0) {
        let jsonData = '';
        try {
          jsonData = JSON.parse(data);
          console.log("receive: ", jsonData);
        } catch(e) {
          console.log(e)
        }

        const helloType = false;
        this.isSetHello = false;
        let strValueTmp = '';
        const params = jsonData;
        const multiWxObj = {
          type: 'multiple',
          data: [],
        };

        const curNode = params;
        let wxObj = {};

        if (jsonData.module === 'task_engine' || jsonData.module === 'faq') {
          const strNodes = curNode.value.split('<br/><br/><br/>');
          let strValue = '';
          let strData = [];
          for (let m = 0; m < strNodes.length; m += 1) {
            const strArray = strNodes[m].split('<br/><br/>');
            if (strArray.length === 1) {
              if (strNodes.length === 1) {
                strValue = strArray[0];
              } else {
                strValueTmp = strArray[0];
              }
              strData = curNode.data;
            } else {
              strValue = strArray[0];
              // const strData = [];
              if (strArray.length > 1) {
                const sqData = strArray[1].split('<br>');
                for (let j = 0; j < sqData.length; j += 1) {
                  if (j < 5) {
                    strData.push(sqData[j]);
                  } else if (sqData[j].trim().length > 0) {
                    this.sqList.push(sqData[j]);
                  }
                }
                curNode.subType = 'guslist';
              }
            }
          }
          wxObj = {
            type: 'text',
            subType: curNode.subType,
            value: strValue,
            data: strData,
            nextNum: this.sqList.length,
            valueTmp: strValueTmp,
            isHello: helloType,
          };
        } else {
          wxObj = {
            type: 'text',
            subType: 'text',
            value: curNode.mess,
            data: curNode.data,
            valueTmp: strValueTmp,
            isHello: helloType,
          };
        }
        if (curNode.subType === 'image') {
          wxObj = {
            type: 'text',
            subType: 'image',
            value: `${curNode.value.trim()}`,
            isHello: helloType,
          };
          this.appendChat(wxObj, 'robot');
          // multiWxObj.data.push(wxObj);
        }
        if (curNode.subType === 'image_im') {
          wxObj = {
            type: 'text',
            subType: 'image',
            value: `${curNode.value.trim()}`,
            isHello: helloType,
          };
          this.appendChat(wxObj, 'robot');
          // multiWxObj.data.push(wxObj);
        }
        if (curNode.subType === 'relatelist') {
          wxObj = {
            type: 'text',
            subType: 'relatelist',
            value: `${curNode.value.trim()}`,
            data: curNode.data,
            isHello: helloType,
          };
          // this.appendChat(wxObj, 'robot');
        }
        this.appendChat(wxObj, 'robot');
      }
    },
    appendChat(answerobj, role = 'user') {
      const chatobj = {
        role,
        uuid: this.uuid,
        feedback: "",
        feedBackMessage: "",
        feedbackMessageImg: true,
        feedBackLiStyle: {"display":"none"},
        feedBackInputStyle: {"display":"none"},
        submitButton: {"display":"none"}
      };
      answerobj.time = new Date().getTime();
      answerobj.isShow = true;
      Object.assign(chatobj, answerobj);
      this.chatList.push(chatobj);
      this.log(this.chatList);
      this.$nextTick(this.scrollToBottom);
    },
    inputBlur(e) {
      if (e.target.id === 'userInput') {
        this.sendText();
      }
      setTimeout(() => {
        document.body.scrollTop = 0;
      }, 0);
    },
    inputFocus() {
      setTimeout(() => {
        document.body.scrollTop = document.body.scrollHeight;
      }, 300);
    },
    handleShowFun() {
      this.isexpand = !this.isexpand;
      if (this.isexpand) {
        this.scrollToBottom();
      }
    },
    handleClickFun(type) {
      this.isexpand = false;
      if (type === 'rate') {
        this.showRate = true;
        return;
      }
      this.sendUserText(type, true);
    },
    closePop() {
      this.showRate = false;
    },
    submitRate() {
      this.$message({
        message: '感谢您的评价！',
        type: 'success',
      });
      this.$refs.popWin.closePop();
    },
    scrollToBottom() {
      const chatbox = document.getElementById('chatBox');
      chatbox.scrollTop = chatbox.scrollHeight + 1000;
    },
    initWebSocket(senderID) {
      return new Promise((resolve, reject) => {
        if ('WebSocket' in window) {
          this.webSocket = null;
          const ishttps = document.location.protocol === 'https:';
          const domain = this.getDomain();
          if (ishttps) {
            this.webSocket = new WebSocket(`ws://${domain}/websocket/${senderID}`);
          } else {
            this.webSocket = new WebSocket(`ws://${domain}/websocket/${senderID}`);
            console.log(`ws://${domain}/websocket/${senderID}`)
          }
          // 連接錯誤
          this.webSocket.onerror = this.setErrorMessage;
          // 連接成功
          this.webSocket.onopen = this.setOnopenMessage;
          // 收到消息的回調
          this.webSocket.onmessage = this.setOnmessageMessage;
          // 连接关闭的回調
          this.webSocket.onclose = this.setOncloseMessage;
          // 監聽窗口關閉事件，當窗口關閉時，主動去關閉websocket連接，防止連接還沒斷開就關閉窗口，server端會拋異常。
          window.onbeforeunload = this.onbeforeunload;

          this.webSocketTimer = setInterval(() => {
              this.intervalWebsocketConnect()
              console.log('websocket init with senderID:',senderID)
              if (this.webSocketIsInit) {
                resolve(true);
              }
            }, 100)
          } else {
            reject(false);
          }
      });
    },
    getQueryString(name) {
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
    setCookie(name, value) {
      const Days = 1;
      const exp = new Date();
      const timetoday = parseInt(exp.getTime(), 10);
      const timelastday = parseInt((Days * 24 * 60 * 60 * 1000), 10);
      const timestamp = timetoday + timelastday;
      exp.setTime(timestamp);
      document.cookie = `${name}=${escape(value)};expires=${exp.toGMTString()}`;
    },
    getCookie(name) {
      const reg = new RegExp(`(^| )${name}=([^;]*)(;|$)`);
      const arr = document.cookie.match(reg);
      if (arr) {
        return arr[2];
      }
      return null;
    },
    setErrorMessage() {
      this.data = `WebSocket connect error, status:${this.webSocket.readyState}`;
    },
    setOnopenMessage() {
      this.data = `WebSocket connect success, status:${this.webSocket.readyState}`;
    },
    setOnmessageMessage(event) {
      const message = event.data;
      this.data = `bot response：${message}`;
      this.log(this.data);
      if (this.mess.mess !== message) {
          this.handleProcessAnswer(message);
      }
    },
    setOncloseMessage() {
      this.data = `WebSocket connection close, status:${this.webSocket.readyState}`;
    },
    onbeforeunload() {
      this.closeWebSocket();
    },

    // websocket发送消息
    send() {
      this.webSocket.send(this.text);
      this.text = '';
    },
    closeWebSocket() {
      this.webSocket.close();
    },
    showTimes(val, idx) {
      const time = val.time;
      const role = val.role;
      const that = this;
      const timeObj = {};
      const tdate = new Date(time);
      const hour = tdate.getHours() < 10 ? `0${tdate.getHours()}` : tdate.getHours();
      const minute = tdate.getMinutes() < 10 ? `0${tdate.getMinutes()}` : tdate.getMinutes();
      timeObj.time = `${hour}:${minute}`;
      // 如果前一比出話時間分鐘數與當前這筆相同隱藏前一筆
      if (idx !== 0 && !val.showTimeProcessed ) {
        if ( !val.showTimeProcessed && role === this.chatList[idx-1].role && Math.floor(this.chatList[idx].time/60000) === Math.floor(this.chatList[idx-1].time/60000) ) {
          this.chatList[idx].isShow = true;
          this.chatList[idx-1].isShow = false;
        }
        val.showTimeProcessed = true;
      }
      // 用最後一筆出話時間刷新 titleTime
      that.titleTime = tdate.getMonth() + 1 +'/' + tdate.getDate();
      return timeObj;
    },
    inputFocusFun(e) {
      if (!!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/)) {
        setTimeout(() => {
          if (this.scrollY === 0) {
            this.scrollY = window.scrollY;
          }
          document.body.style.height = (this.winHeight - this.scrollY) + 'px';
          window.scroll(0, 0);
        }, 400)
      }
    },
    inputBlurFun() {
      if (!!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/)) {        
        setTimeout(() => {
          document.body.style.height = this.winHeight + 'px';
          window.scroll(0, 0);
        }, 400)
      }
    },
    onresize() {
      if (/android/i.test(navigator.userAgent)) {
        this.$nextTick(this.scrollToBottom);
      }
    },
    log(str, obj) {
      if (this.isDebug){
        if (obj){
          console.log(str, obj);
        } else {
          console.log(str);
        }
      }
    },
  },
};
</script>

<style lang="scss">
@import '../assets/styles/variables.scss';
img {
  width: auto !important;
  height: auto !important;
  max-width: 100% !important;
}
.statis-faction {
  width: 460px;
  // border-top: #eee 1px solid;
  margin: 5px 5px 5px;
  padding: 0px 0;
  display: flex;
  justify-content: left;
  li {
    width: 50px;
    height: 30px;
    line-height: 28px;
    text-align: center;
    box-sizing: border-box;
    border: #B0B4BB 1px solid;
    border-radius: 15px;
    margin: 0 7px;
    padding: 0;
    color: #909399;
    font-size: $text-font-size;
    display: flex;
    justify-content: center;
    &.solve {
      &:before {
        content: '';
        display:inline-block;
        width: 20px;
        height: 20px;
        margin:4px 1px 0 0;
        background: url(../assets/images/icon_good.png) -1px -1px no-repeat;
        background-size: 22px 22px;
        transform: rotateX(180deg);
      }
      &.selected {
        border: #68bcff 0px solid;
        color: #68bcff;
        background-color:#68bcff;
        &:before {
          background-image: url(../assets/images/icon_good_on.png)
        }
      }
    }
    &.feedback-message-img {
      background: url(../assets/images/chat.png) 2px 2px no-repeat;
      background-size: 42px 22px;
    }
    &.unsolve {
      &:before {
        content: '';
        display:inline-block;
        width: 20px;
        height: 20px;
        margin:4px 1px 0 0;
        background: url(../assets/images/icon_good.png) -1px -1px no-repeat;
        background-size: 22px 22px;
      }
      &.selected {
        border: #68bcff 0px solid;
        color: #68bcff;
        background-color:#68bcff;
        &:before {
          background-image: url(../assets/images/icon_good_on.png)
        }
      }
    }
  }
}

.frame{
  display: flex;
  flex-direction: row;
  height: 100%;
}
.chat-bot{
  width: 50%;
}

.selection-top {
  width: 100%;
  display: flex;
}

.chat-body-txt-link {
  cursor: pointer;
}

.dropdown:hover,
.dropdown.active{
  background: #444;
  border-bottom: 3px solid #eb4559;
  cursor: pointer;
}
  
.dropdown-menu-left {
  position: absolute;
  background: #444;
  width: 100%;
  padding: 0px;
  top: calc(100% + 3px);
  left:0;
  margin: 0;
}

$padding-primary: 10px;
.icon-close {
  margin-left: 10px;
  flex-shrink: 0;
  width: 14px;
  height: 14px;
  background: url(../assets/images/close.png);
  background-size: 14px 14px;
}
.icon-robot {
  width: 40px;
  height: 40px;
  background: url(../assets/images/KGI_chatbot.png);
  background-size: 40px 40px;
}
.icon-user {
  width: 40px;
  height: 40px;
  // background: url(../assets/images/head_user.png);
  // background-size: 40px 40px;
  img {
    width: 40px;
    height: 40px;
    border-radius: 5px;
  }
}

.icon-robot-1{
  width: 45px;
  height: 48px;
  background: url(../assets/images/KGI_chatbot.png);
  background-size: 45px 48px;
}

@media (min-width: 560px) {
  .robot-chat-wrap {
    width: 400px;
  }
}

.robot-chat-wrap {
  margin:0 auto;
  position: relative;
  height: 100%;
  z-index: 10;
  background: #FFFFFF;
  @include flex-box();
  flex-direction: column;
  flex-shrink: 0;
  .note-wrap {
    height: 40px;
    padding: 0 $padding-primary;
    @include flex-box();
    flex-shrink: 0;
    align-items: center;
    height: 40px;
    box-sizing: border-box;
    transition: height ease 100ms;
    &.close {
      height: 0;
      overflow: hidden;
    }
    .note-title {
      font-size: $text-font-size;
      color: #f8a849;
      flex-shrink: 0;
    }
  }
  .chat-wrap {
    padding: 17px $padding-primary;
    box-sizing: border-box;
    overflow: auto;
    flex: 1;
    -webkit-overflow-scrolling: touch;
    .chat-box {
      width: 100%;
      .chat-time {
        // text-align: center;
        line-height: 20px;
        font-size: 14px;
        color: #BBBCCD;
        margin: 0px 10px 10px 10px;
      }
      .left {
        text-align: left;
      }
      .right {
        text-align: right;
      }
      .chat-content {
      @include flex-box();
      margin-bottom: 0px;
      .chat-body {
        padding: 10px 16px;
        box-sizing: border-box;
        min-width: 15px;
        max-width: 75%;
        max-width: calc(100% - 90px);
        min-height: 32px;
        line-height: 20px;
        font-size: $text-font-size;
        color: #303133;
        .chat-body-txt {
          color: #303133;
          font-size: $text-font-size;
          white-space: normal;
          overflow-wrap: break-word;
          img {
            width: auto !important;
            height: auto !important;
            max-width: 100% !important;
          }
          .statis-faction {
            width: 266px;
            border-top: #eee 1px solid;
            margin: 10px -20px 0;
            padding: 20px 0;
            display: flex;
            justify-content: center;
            li {
              width: 101px;
              height: 30px;
              line-height: 28px;
              text-align: center;
              box-sizing: border-box;
              border: #B0B4BB 1px solid;
              border-radius: 15px;
              margin: 0 7px;
              padding: 0;
              color: #909399;
              font-size: $text-font-size;
              display: flex;
              justify-content: center;
              text-shadow:5px 5px 3px #444;
              &.solve {
                &:before {
                  content: '';
                  display:inline-block;
                  width: 20px;
                  height: 20px;
                  margin:4px 1px 0 0;
                  background: url(../assets/images/icon_good.png) -1px -1px no-repeat;
                  background-size: 22px 22px;
                  transform: rotateX(180deg);
                }
                &.selected {
                  border: #1f6adb 1px solid;
                  color: #1f6adb;
                  &:before {
                    background-image: url(../assets/images/icon_good_on.png)
                  }
                }
              }
              &.unsolve {
                &:before {
                  content: '';
                  display:inline-block;
                  width: 20px;
                  height: 20px;
                  margin:4px 1px 0 0;
                  background: url(../assets/images/icon_good.png) -1px -1px no-repeat;
                  background-size: 22px 22px;
                }
                &.selected {
                  border: #1f6adb 1px solid;
                  color: #1f6adb;
                  &:before {
                    background-image: url(../assets/images/icon_good_on.png)
                  }
                }
              }
            }
          }
        }
        .chat-body-txt-link {
          color: #1f6adb;
          font-size: $text-font-size;
          white-space: normal;
          overflow-wrap: break-word;
        }
        a {
          color: #1f6adb;
        }
      }
      }
      &.robot {
        .chat-content {
        justify-content: left;
        .chat-body {
          margin: 0px 0px 7px 5px;
          border-radius: 0 14px 14px 14px;
          // border: 1px solid black;
          // box-shadow: 0px 0px 20px orange inset;
          background-color: #f5f5f5;
          box-shadow: 0 0 4px rgba(0,0,0,0.1);
          .multi-recom {
            margin: 10px -16px 0;
            padding: 10px 16px 0;
            border-top: #eee 1px solid;
            .img-box {
              img {
                max-width: 234px;
                margin: 0;
                border-radius: 0;
              }
            }
          }
          &.chat-have-faq {
            box-shadow: none;
            padding: 0;
            background: none;
            .chat-body-txt {
              padding: 10px 16px;
              box-sizing: border-box;
              min-height: 32px;
              line-height: 20px;
              font-size: $text-font-size;
              color: #303133;
              border-radius: 0 20px 20px 20px;
              background-color: #f5f5f5;
              box-shadow: 0 0 4px rgba(0,0,0,0.1);
              display: inline-block;
            }
            .faq-list {
              width: 100%;
              min-width: 276px;
              display: flex;
              flex-wrap: wrap;
              margin-right: -500px;
              margin-top: 4px;
              li {
                cursor: pointer;
                display: inline-block;
                height: 30px;
                border: #1f6adb 1px solid;
                border-radius: 15px;
                // white-space: nowrap;
                background: #f5f5f5;
                margin: 3px 10px 3px 0;
                line-height: 28px;
                padding: 0 15px;
                color: #1f6adb;
                font-size: $text-font-size;
                box-sizing: border-box;
              }
            }
          }
          .rq-box {
            line-height: 20px;
            font-size: 15px;
            &.marginTop {
              margin-top: 10px;
            }
            span {
              color: #303133;
              &.relateTit {
                color:#909399;
                font-size:14px;
                display: block;
                // margin-bottom: 10px;
              }
            }
            ul {
              padding-bottom: 5px;
              li {
                color: #1f6adb;
                margin: 10px 0 0;
              }
            }
            img {
              width: auto !important;
              height: auto !important;
              max-width: 226px !important;
            }
          }
        }
        .img-box {
          img {
            margin-left: 5px;
            max-width: 266px;
            border-radius: 0 20px 20px 20px;
          }
        }
        }
      }
      &.user {
        .chat-content {
        margin-bottom: 7px;
        justify-content: flex-end;
        .chat-body {
          border-radius: 14px 0 14px 14px;
          margin-right: 5px;
          // border: 1px solid black;
          background-color: #1f6adb;
        }
        }
      }
    }
  }
  .input-wrap {
    .input-wrapper {
      padding: 10px 15px;
      @include flex-box();
      // padding: 10px $padding-primary;
      background-color: #f5f5f5;
      height: 36px;
      line-height: 36px;
      li {
        color: white;
        font-size: $text-font-size;
      }
      .left {
        width: calc(100% - 55px);
      }
      .right {
        width: 55px;
      }
      input {
        margin: 0 0 0 2px;
        padding: 0 16px;
        flex: 1;
        border: none;
        font-size: $text-font-size;
        border-radius: 18px;
        box-sizing: border-box;
        color: #303133;
        height: 36px;
        width: 100%;
        background: #FFFFFF;
      }
      .btn-submit {
        margin: 0;
        border: 0;
        text-align: center;
        width: 36px;
        height: 36px;
        margin-left: 10px;
        padding: 0;
        background: none;
      }
      .icon-submit {
        // background: url(../assets/images/icon_send_on.svg) -5px -6px no-repeat;
        width: 55px;
        height: 36px;
        background: #c7cbd1;
        background-size: 44px 44px;
        vertical-align: middle;
        border-radius: 10px;
      }
      .icon-submit-disabled {
        width: 55px;
        height: 36px;
        background:#1f6adb;
        background-size: 44px 44px;
        vertical-align: middle;
        border-radius: 10px;
      }
    }
  }
  .other-wrap {
    display: none;
    position: absolute;
    left: -20px;
    bottom: 125px;
    .bubble-main {
      position: relative;
      border-radius: 100%;
      // border: 10px solid #00bffe;
      box-shadow: 0px 0px 25px orange inset;
      -webkit-box-shadow:0px 0px 20px orange inset;
      -webkit-appearance:none;
      width: 86px;
      height: 86px;
      text-align: center;
      line-height: 76px;
      z-index: 2;
      i {
        vertical-align: middle;
      }
    }
    .bubble-small {
      position: absolute;
      display: inline-block;
      border-radius: 100%;
      box-shadow: 0px 0px 20px orange inset;
      -webkit-box-shadow:0px 0px 20px orange inset;
      -webkit-appearance:none;
      width: 40px;
      height: 40px;
      color: black;
      text-align: center;
      line-height: 40px;
      font-size:$text-font-size;
      transform: translate(30px, -75px);
      opacity: 0;
      transition: opacity ease 300ms, transform ease 300ms;
    }
    &.expand {
      .bubble-small {
        opacity: 1;
        transform: translate(58px, -126px);
        transition: opacity ease 300ms, transform ease 300ms;
        &:nth-child(3) {
          transform: translate(89px, -93px);
        }
        &:nth-child(4) {
          transform: translate(93px, -47px);
        }
      }
    }
  }
}
.score-title {
  margin-bottom: 20px;
  font-size: $font-size-20;
  color: $color-font-43;
  text-align: center;
}
.btn-submit-rate {
  margin-top: 50px;
  border-radius: 8px;
  background-color: #2885fe;
  color: #fff;
  outline: 0;
  border: 0;
  width: 100%;
  height: 50px;
  font-size: $font-size-24;
}
.el-message {
  min-width: 200px;
  .el-icon-success {
    display: none;
  }
}
.deskHeaderClose {
  width: 14px;
  height: 8px;
  display: block;
  background: url(../assets/images/insert/icons_ins.png) -186px -32px no-repeat;
  position: absolute;
  right: 21px;
  top: 18px;
}
.deskHeaderBack {
  width: 40px;
  height: 44px;
  display: block;
  background: url(../assets/images/icon_back.png) 11px 15px no-repeat;
  background-size: 17px;
  position: absolute;
  left: 0px;
  top: 0px;
}
.deskConHeaderXm {
  background:#FFFFFF;
  position: relative;
  text-align: center;
  line-height: 22px;
}
.connorTitle {
  p {
    text-align: center;
    line-height: 20px;
    font-size: 14px;
    color: #BBBCCD;
    margin-bottom: 3px;
    margin-top: 2px;
  }
  margin-top: 0;
  margin-left: 0;
  font-size: 17px !important;
  color: #303133;
  // font-weight: normal;
}
.robot-chat-web {
  .icon {
    border-radius: 50%;
    img {
      border-radius: 50%;
    }
  }
}
</style>
