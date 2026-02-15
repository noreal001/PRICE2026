
<template>
  <div class="bahur-terminal" :style="themeVars">
    <svg style="position:absolute;width:0;height:0;overflow:hidden"><defs><filter id="glass-distort" x="-5%" y="-5%" width="110%" height="110%"><feTurbulence type="fractalNoise" baseFrequency="0.015" numOctaves="3" seed="2" result="noise"/><feGaussianBlur in="noise" stdDeviation="2" result="sN"/><feDisplacementMap in="SourceGraphic" in2="sN" scale="3" xChannelSelector="R" yChannelSelector="G"/></filter></defs></svg>
    <div class="container">
      <!-- Header -->
      <header class="header-bar">
        <button @click="showDash=!showDash" :class="['glass-pill',{active:showDash}]"><span class="gpi"><span class="gpt main-font">СТАТИСТИКА</span></span></button>
        <div class="logo kollektif">BAHUR</div>
        <button @click="toggleThemeMenu" ref="themeBtnRef" :class="['glass-pill',{active:showThemeMenu}]"><span class="gpi"><span class="gpt main-font">ДИЗАЙН</span></span></button>
      </header>

      <!-- Theme Menu -->
      <teleport to="body"><transition name="pop"><div v-if="showThemeMenu" class="popup-teleport dpop" :style="[themeMenuStyle,pVars]"><div class="drow"><button v-for="t in darkThemes" :key="t.id" @click="selTheme(t.id)" :class="['sw',{active:curTheme===t.id}]" :style="t.pv"><span v-if="t.dot" class="sw-dot" :style="{background:t.dot}"></span></button></div><div class="dsep"></div><div class="drow"><button v-for="t in lightThemes" :key="t.id" @click="selTheme(t.id)" :class="['sw',{active:curTheme===t.id}]" :style="t.pv"><span v-if="t.dot" class="sw-dot" :style="{background:t.dot}"></span></button></div></div></transition></teleport>

      <!-- Loading -->
      <div v-if="loading" class="lo"><div class="lo-bg"></div><div class="lo-c"><span class="lo-t main-font">BAHUR</span></div></div>

      <!-- Error -->
      <div v-if="errorMsg" class="ez"><div class="eb"><div style="font-size:30px;margin-bottom:15px;opacity:.8">✕</div><h3 class="mono" style="font-size:14px;margin-bottom:10px;letter-spacing:1px">ОШИБКА ПОДКЛЮЧЕНИЯ</h3><p style="font-size:12px;color:var(--dim);margin-bottom:25px">{{ errorMsg }}</p><button @click="loadData" style="background:var(--text);border:none;color:var(--bg);padding:12px 24px;font-size:11px;cursor:pointer;font-weight:700" class="mono">ПОВТОРИТЬ</button></div></div>

      <div v-else-if="!loading">
        <!-- Dashboard -->
        <div :class="['dw',{open:showDash}]"><div class="dc"><section class="dg">
          <div class="sc"><label class="sl">АРОМАТЫ</label><div class="sv mono">{{ stats.total }}</div><div class="ss"><span>Есть: <b class="mono">{{ stats.countAvail }}</b></span><span>Нет: <b class="mono">{{ stats.countOut }}</b></span></div></div>
          <div class="sc"><label class="sl">СКЛАД</label><div class="sv mono">{{ stats.availability }}%</div><div class="bt"><div class="bf" :style="{width:stats.availability+'%'}"></div></div></div>
          <div class="sc"><label class="sl">СРЕДНЯЯ ЦЕНА</label><div class="sp2"><div v-if="showPrices.p50" class="sp3">50г: <span class="mono">{{ stats.avg50 }}₽</span></div><div v-if="showPrices.p500" class="sp3">500г: <span class="mono">{{ stats.avg500 }}₽</span></div><div v-if="showPrices.p1000" class="sp3">1кг: <span class="mono">{{ stats.avg1000 }}₽</span></div></div></div>
          <div class="sc"><label class="sl">ФАБРИКИ</label><div v-for="f in ['LUZI','EPS','SELUZ']" :key="f" class="br"><div class="bm"><span class="mono">{{ f }}</span><span class="mono">{{ stats.factoryPerc[f] }}%</span></div><div class="bn"><div class="bf" :style="{width:stats.factoryPerc[f]+'%'}"></div></div></div></div>
          <div class="sc"><label class="sl">КАЧЕСТВО</label><div v-for="q in ['TOP','Q1','Q2']" :key="q" class="br"><div class="bm"><span class="mono">{{ q }}</span><span class="mono">{{ stats.qualityPerc[q] }}%</span></div><div class="bn"><div class="bf" :style="{width:stats.qualityPerc[q]+'%'}"></div></div></div></div>
          <div class="sc sw2"><div style="display:flex;justify-content:center;margin-bottom:6px"><button @click="toggleStatsMode" class="tsw main-font"><span style="color:var(--dim)">РЕЙТИНГ:</span> {{ statsMode==='6m'?'6 МЕС':'ВСЕ ВРЕМЯ' }} ⇄</button></div><div class="tsc"><div v-for="(item,idx) in stats.topListFull" :key="idx" class="tr2"><div class="tl"><span class="tn mono">{{ idx+1 }}.</span><span class="tname kollektif">{{ item.name }}</span></div><div class="tb2"><div class="tbd">{{ item.factory }}</div><div class="tbd">{{ item.quality }}</div><div class="tbd tbh">{{ statsMode==='6m'?item.sales6m:item.salesAll }}%</div></div><div style="display:flex;align-items:center"><div class="bn"><div class="bf" :style="{width:(statsMode==='6m'?item.sales6m:item.salesAll)+'%'}"></div></div></div></div><div v-if="!stats.topListFull.length" class="mono" style="font-size:10px;opacity:.5">НЕТ ДАННЫХ</div></div></div>
        </section></div></div>

        <!-- Overlay -->
        <div v-if="anyMenuOpen" class="co" @click="closeAllMenus"></div>

        <div class="tf">
          <!-- Sticky Nav -->
          <div class="sn">
            <section class="ni">
              <!-- Row 1: Brands + Fragrances -->
              <div class="ntr ntr-main">
                <div ref="brandBtnRef"><button @click="toggleBrandMenu" :class="['glass-pill compact filter-pill',{active:showBrandMenu||selectedBrands.length>0}]"><span class="gpi"><span class="gpt main-font">{{ brandLabel }}</span></span></button></div>
                <div ref="fragBtnRef"><button @click="toggleFragMenu" :class="['glass-pill compact filter-pill',{active:showFragMenu||selectedFrags.length>0}]"><span class="gpi"><span class="gpt main-font">{{ fragLabel }}</span></span></button></div>
                <div class="nav-sep"></div>
                <div ref="statusBtnRef"><button @click="toggleNewMenu" :class="['glass-pill compact',{active:showNewMenu||filterPlus||filterStar||showOut}]"><span class="gpi"><span class="gpt main-font">НОВИНКИ</span></span></button></div>
                <div ref="filterBtnRef"><button @click="toggleFilterMenu" :class="['glass-pill compact',{active:showFilters}]"><span class="gpi"><span class="gpt main-font">{{ showFilters?'ЗАКРЫТЬ':'ФИЛЬТРЫ' }}</span></span></button></div>
              </div>
            </section>
            <!-- Table header -->
            <div class="th" :class="'sz-'+cardSize">
              <div class="hn hbrand"><span class="hp nhp kollektif">БРЕНД</span></div>
              <div class="hn haroma"><span class="hp nhp kollektif">АРОМАТ</span></div>
              <div class="hpl do"><span class="hp mhp kollektif">ПОЛ</span></div>
              <div class="hpl do"><span class="hp mhp kollektif">ФАБРИКА</span></div>
              <div class="hpl do"><span class="hp mhp kollektif">КАЧЕСТВО</span></div>
              <div class="hpr" :style="psg"><div v-if="showPrices.p50" class="hpl"><span class="hp php mono">50г</span></div><div v-if="showPrices.p500" class="hpl"><span class="hp php mono">500г</span></div><div v-if="showPrices.p1000" class="hpl"><span class="hp php mono">1кг</span></div></div>
            </div>
          </div>

          <!-- Popups -->
          <teleport to="body">
            <!-- Brand Menu -->
            <transition name="pop"><div v-if="showBrandMenu" class="popup-teleport" :style="[brandMenuStyle,pVars]"><div style="width:100%"><input v-model="tempBrandInput" type="search" inputmode="search" enterkeyhint="search" placeholder="ПОИСК БРЕНДА…" class="pinp main-font"/></div><div class="bsc"><button @click="clearBrands" class="bbtn ab main-font"><svg style="width:14px;height:14px;flex-shrink:0" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12S6.5 22 12 22 22 17.5 22 12 17.5 2 12 2M10 17L5 12L6.41 10.59L10 14.17L17.59 6.58L19 8L10 17Z"/></svg><span>ВСЕ</span></button><button v-for="b in filteredBrandsDropdown" :key="b" @click="toggleBrandSelection(b)" class="bbtn main-font"><span class="btx">{{ b }}</span><svg v-if="selectedBrands.includes(b)" style="width:13px;height:13px" viewBox="0 0 24 24"><path fill="currentColor" d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"/></svg></button><div v-if="!filteredBrandsDropdown.length" style="font-size:10px;color:var(--dim);padding:6px 10px" class="main-font">НЕТ СОВПАДЕНИЙ</div></div></div></transition>
            <!-- Fragrance Menu -->
            <transition name="pop"><div v-if="showFragMenu" class="popup-teleport" :style="[fragMenuStyle,pVars]"><div style="width:100%"><input v-model="tempFragInput" type="search" inputmode="search" enterkeyhint="search" placeholder="ПОИСК АРОМАТА…" class="pinp main-font"/></div><div class="bsc"><button @click="clearFrags" class="bbtn ab main-font"><svg style="width:14px;height:14px;flex-shrink:0" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12S6.5 22 12 22 22 17.5 22 12 17.5 2 12 2M10 17L5 12L6.41 10.59L10 14.17L17.59 6.58L19 8L10 17Z"/></svg><span>ВСЕ</span></button><button v-for="f in filteredFragsDropdown" :key="f" @click="toggleFragSelection(f)" class="bbtn main-font"><span class="btx">{{ f }}</span><svg v-if="selectedFrags.includes(f)" style="width:13px;height:13px" viewBox="0 0 24 24"><path fill="currentColor" d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"/></svg></button><div v-if="!filteredFragsDropdown.length" style="font-size:10px;color:var(--dim);padding:6px 10px" class="main-font">НЕТ СОВПАДЕНИЙ</div></div></div></transition>
            <!-- Status Menu -->
            <transition name="pop"><div v-if="showNewMenu" class="popup-teleport" :style="[statusMenuStyle,pVars]"><div class="tgr" @click="filterPlus=!filterPlus"><span class="tgl main-font">НОВИНКИ <span class="ch chp">+</span></span><div :class="['tg',{on:filterPlus}]"><div class="tgt"></div></div></div><div class="tgr" @click="filterStar=!filterStar"><span class="tgl main-font">ВЕРСИИ <span class="ch chs">*</span></span><div :class="['tg',{on:filterStar}]"><div class="tgt"></div></div></div><div class="tgr" @click="showOut=!showOut"><span class="tgl main-font">НЕТ <span class="ch chm">-</span></span><div :class="['tg',{on:showOut}]"><div class="tgt"></div></div></div></div></transition>
            <!-- Filters Menu -->
            <transition name="pop"><div v-if="showFilters" class="popup-teleport" :style="[filterMenuStyle,pVars]">
              <div class="ps"><span class="pl main-font">ПОЛ</span><div class="sg"><button v-for="g in genderOptions" :key="g.val" @click="activeGender=g.val" :class="['sgb main-font',{active:activeGender===g.val}]">{{ g.label }}</button></div></div>
              <div class="ps"><span class="pl main-font">ФАБРИКА</span><div class="sg"><button v-for="f in factoryOptions" :key="f.val" @click="activeFactory=f.val" :class="['sgb main-font',{active:activeFactory===f.val}]">{{ f.label }}</button></div></div>
              <div class="ps"><span class="pl main-font">КАЧЕСТВО</span><div class="sg"><button v-for="q in qualityOptions" :key="q.val" @click="activeQuality=q.val" :class="['sgb main-font',{active:activeQuality===q.val}]">{{ q.label }}</button></div></div>
              <div class="ps"><span class="pl main-font">ЦЕНА</span><div class="sg"><button v-for="s in sortOptions" :key="s.val" @click="sortBy=s.val" :class="['sgb main-font',{active:sortBy===s.val}]"><span v-if="s.val==='id'">ID</span><span v-else>{{ s.label }}{{ s.val==='asc'?'▲':'▼' }}</span></button></div></div>
              <div class="ps"><span class="pl main-font">СТОЛБЦЫ</span><div class="sg"><button v-for="(val,key) in priceLabels" :key="key" @click="togglePrice(key)" :class="['sgb main-font',{active:showPrices[key]}]">{{ val }}</button></div></div>
              <div class="ps"><span class="pl main-font">РАЗМЕР</span><div class="sg"><button v-for="sz in sizeOptions" :key="sz.val" @click="cardSize=sz.val" :class="['sgb main-font',{active:cardSize===sz.val}]">{{ sz.label }}</button></div></div>
            </div></transition>
          </teleport>

          <!-- Products -->
          <div class="gt" :class="'sz-'+cardSize">
            <div v-for="(p,index) in sortedProducts" :key="p.id+'-'+index" :class="['row','cr',{out:p.isOut,'sh':autoHighlightId===p.id}]" @click="p.link&&p.link.length>5?openLink(p.link):null">
              <div class="rc">
                <!-- Brand column -->
                <div class="cn cbrand"><div class="pn pn-brand"><span class="bc kollektif">{{ p.brand }}</span></div></div>
                <!-- Aroma column -->
                <div class="cn caroma"><div class="pn pn-aroma">
                  <span class="st2 kollektif">{{ p.name }}</span>
                  <div class="mm"><span class="mb kollektif">{{ getSex(p.gender) }}</span><span class="mb kollektif">{{ p.factory }}</span><span class="mb kollektif">{{ p.quality }}</span></div>
                  <!-- ID badge top-right -->
                  <span class="id-badge mono">{{ p.id }}<span v-if="p.isOut" class="id-st" style="color:#fd4659">-</span><span v-else-if="p.hasPlus" class="id-st" style="color:#00a86b">+</span><span v-else-if="p.hasStar" class="id-st" style="color:#a020f0">*</span></span>
                </div></div>
                <!-- Desktop meta -->
                <div class="cm do center"><div class="pm kollektif">{{ getSex(p.gender) }}</div></div>
                <div class="cm do center"><div class="pm kollektif">{{ p.factory }}</div></div>
                <div class="cm do center"><div class="pm kollektif">{{ p.quality }}</div></div>
                <!-- Prices -->
                <div class="cp" :style="psg"><div v-if="showPrices.p50" class="pp mono" :style="{color:accentColor}">{{ p.p50 }}₽</div><div v-if="showPrices.p500" class="pp mono" :style="{color:accentColor}">{{ p.p500 }}₽</div><div v-if="showPrices.p1000" class="pp mono fw8" :style="{color:accentColor}">{{ p.p1000 }}₽</div></div>
              </div>
              <!-- Subtle dot at bottom center -->
              <div class="row-dot"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- Scroll Track -->
    <div v-if="!loading&&!errorMsg" class="strack" ref="scrollTrack" @mousedown.prevent="startDrag" @touchstart.prevent="startDrag" @click="trackClick"><div class="sthumb" :style="{top:thumbTop+'%',height:thumbHeight+'%'}"></div></div>
  </div>
</template>

<script setup>
import{ref,computed,onMounted,onUnmounted,nextTick,watch}from'vue'

// ── Themes ──
const saved=localStorage.getItem('bahur-theme')
const curTheme=ref(saved||'graphite')
const showThemeMenu=ref(false),themeBtnRef=ref(null),themeMenuStyle=ref({})

const T={
// Dark graphite family
graphite:{bg:'#1e1e22',text:'#e2e2e8',cBg:'#161618',pP:'#101014',pM:'#1a1a20',pN:'#24242c',pS:'#1c1c24',brd:'rgba(255,255,255,0.07)',dim:'#54545e',hBg:'#222228',sBg:'rgba(22,22,24,0.96)',seBg:'#0c0c10',seA:'#e2e2e8',seT:'#404048',seTA:'#0c0c0e',bBg:'rgba(255,255,255,0.05)',bBrd:'rgba(255,255,255,0.09)',lBg:'rgba(255,255,255,0.05)',lBrd:'rgba(255,255,255,0.12)',aura:'#fff',panBg:'#18181c',gBase:'rgba(255,255,255,0.06)',gBrd:'rgba(255,255,255,0.1)',gShine:'rgba(255,255,255,0.14)',acc:'#e2e2e8'},
aurum:{bg:'#1c1a18',text:'#e8e0d0',cBg:'#14120f',pP:'#0e0c08',pM:'#1e1a14',pN:'#282218',pS:'#1e1a12',brd:'rgba(201,169,110,0.12)',dim:'#6a5c48',hBg:'#242018',sBg:'rgba(20,18,15,0.96)',seBg:'#0c0a06',seA:'#e8e0d0',seT:'#5a5040',seTA:'#0c0a06',bBg:'rgba(201,169,110,0.06)',bBrd:'rgba(201,169,110,0.14)',lBg:'rgba(201,169,110,0.06)',lBrd:'rgba(201,169,110,0.16)',aura:'#d4af37',panBg:'#16140f',gBase:'rgba(201,169,110,0.08)',gBrd:'rgba(201,169,110,0.16)',gShine:'rgba(201,169,110,0.2)',acc:'#c9a96e'},
argent:{bg:'#1a1c20',text:'#d8dce6',cBg:'#121418',pP:'#0a0c10',pM:'#181c22',pN:'#20242e',pS:'#1a1e26',brd:'rgba(168,176,200,0.1)',dim:'#50586a',hBg:'#1e2228',sBg:'rgba(18,20,24,0.96)',seBg:'#080a0e',seA:'#d8dce6',seT:'#404858',seTA:'#08090c',bBg:'rgba(168,176,200,0.05)',bBrd:'rgba(168,176,200,0.1)',lBg:'rgba(168,176,200,0.05)',lBrd:'rgba(168,176,200,0.12)',aura:'#c0c8d8',panBg:'#14161a',gBase:'rgba(168,176,200,0.07)',gBrd:'rgba(168,176,200,0.12)',gShine:'rgba(168,176,200,0.16)',acc:'#a8b0c8'},
carbon:{bg:'#121214',text:'#c8c8d0',cBg:'#0c0c0e',pP:'#080808',pM:'#141416',pN:'#1a1a1e',pS:'#12121a',brd:'rgba(255,255,255,0.05)',dim:'#3e3e48',hBg:'#161618',sBg:'rgba(12,12,14,0.96)',seBg:'#060608',seA:'#c8c8d0',seT:'#303038',seTA:'#060608',bBg:'rgba(255,255,255,0.03)',bBrd:'rgba(255,255,255,0.06)',lBg:'rgba(255,255,255,0.03)',lBrd:'rgba(255,255,255,0.08)',aura:'#a0a0b0',panBg:'#0e0e10',gBase:'rgba(255,255,255,0.04)',gBrd:'rgba(255,255,255,0.07)',gShine:'rgba(255,255,255,0.09)',acc:'#8a8a96'},
titanium:{bg:'#1e2026',text:'#e0e2ea',cBg:'#16181e',pP:'#0e1016',pM:'#1a1c24',pN:'#22252e',pS:'#1c1e28',brd:'rgba(180,190,220,0.08)',dim:'#505868',hBg:'#22242c',sBg:'rgba(22,24,30,0.96)',seBg:'#0a0c12',seA:'#e0e2ea',seT:'#404858',seTA:'#0a0c12',bBg:'rgba(180,190,220,0.04)',bBrd:'rgba(180,190,220,0.08)',lBg:'rgba(180,190,220,0.04)',lBrd:'rgba(180,190,220,0.1)',aura:'#e0e4f0',panBg:'#181a20',gBase:'rgba(180,190,220,0.06)',gBrd:'rgba(180,190,220,0.1)',gShine:'rgba(180,190,220,0.14)',acc:'#e0e2ea'},
// Light themes
ivory:{bg:'#faf8f4',text:'#1a1814',cBg:'#fefcf8',pP:'#eae6de',pM:'#f0ece4',pN:'#f6f4ee',pS:'#ece8e0',brd:'rgba(0,0,0,0.06)',dim:'#a09888',hBg:'#f4f0ea',sBg:'rgba(250,248,244,0.96)',seBg:'#dcd6cc',seA:'#1a1814',seT:'#9a9080',seTA:'#fefcf8',bBg:'rgba(0,0,0,0.03)',bBrd:'rgba(0,0,0,0.06)',lBg:'rgba(0,0,0,0.02)',lBrd:'rgba(0,0,0,0.06)',aura:'#1a1814',panBg:'#fcfaf6',gBase:'rgba(255,255,255,0.6)',gBrd:'rgba(0,0,0,0.06)',gShine:'rgba(255,255,255,0.9)',acc:'#6a5c40'},
frost:{bg:'#f0f4f8',text:'#0e1218',cBg:'#f8fafc',pP:'#dce4ee',pM:'#e4eaf4',pN:'#eef2fa',pS:'#e2e8f2',brd:'rgba(0,0,0,0.06)',dim:'#8898ac',hBg:'#eaf0f6',sBg:'rgba(240,244,248,0.96)',seBg:'#ccd6e4',seA:'#0e1218',seT:'#8898ac',seTA:'#f8fafc',bBg:'rgba(0,0,0,0.03)',bBrd:'rgba(0,0,0,0.06)',lBg:'rgba(0,0,0,0.02)',lBrd:'rgba(0,0,0,0.06)',aura:'#0e1218',panBg:'#f6f8fc',gBase:'rgba(255,255,255,0.65)',gBrd:'rgba(0,0,0,0.06)',gShine:'rgba(255,255,255,0.92)',acc:'#3a5070'},
silk:{bg:'#f8f6f4',text:'#121010',cBg:'#fefefe',pP:'#e8e4e0',pM:'#f0ece8',pN:'#f6f4f2',pS:'#ece8e4',brd:'rgba(0,0,0,0.05)',dim:'#a8a098',hBg:'#f2eeea',sBg:'rgba(248,246,244,0.96)',seBg:'#d8d2cc',seA:'#121010',seT:'#a09890',seTA:'#fefefe',bBg:'rgba(0,0,0,0.03)',bBrd:'rgba(0,0,0,0.06)',lBg:'rgba(0,0,0,0.02)',lBrd:'rgba(0,0,0,0.05)',aura:'#121010',panBg:'#fcfafa',gBase:'rgba(255,255,255,0.65)',gBrd:'rgba(0,0,0,0.05)',gShine:'rgba(255,255,255,0.9)',acc:'#5a4838'},
mist:{bg:'#eeeff2',text:'#10111a',cBg:'#f6f7fa',pP:'#dcdee6',pM:'#e4e6ee',pN:'#eef0f6',pS:'#e2e4ec',brd:'rgba(0,0,0,0.06)',dim:'#9098a8',hBg:'#e8eaf0',sBg:'rgba(238,239,242,0.96)',seBg:'#ccd0da',seA:'#10111a',seT:'#8890a0',seTA:'#f6f7fa',bBg:'rgba(0,0,0,0.04)',bBrd:'rgba(0,0,0,0.07)',lBg:'rgba(0,0,0,0.02)',lBrd:'rgba(0,0,0,0.06)',aura:'#10111a',panBg:'#f4f5f8',gBase:'rgba(255,255,255,0.55)',gBrd:'rgba(0,0,0,0.07)',gShine:'rgba(255,255,255,0.85)',acc:'#404860'},
porcelain:{bg:'#ffffff',text:'#0c0c12',cBg:'#fefefe',pP:'#e8e8f0',pM:'#f0f0f6',pN:'#f8f8fc',pS:'#ececf4',brd:'rgba(0,0,0,0.05)',dim:'#b0b0c0',hBg:'#f6f6fc',sBg:'rgba(255,255,255,0.96)',seBg:'#dcdcea',seA:'#0c0c12',seT:'#aaaabc',seTA:'#fefefe',bBg:'rgba(0,0,0,0.03)',bBrd:'rgba(0,0,0,0.06)',lBg:'rgba(0,0,0,0.02)',lBrd:'rgba(0,0,0,0.06)',aura:'#0c0c12',panBg:'#fefefe',gBase:'rgba(255,255,255,0.7)',gBrd:'rgba(0,0,0,0.06)',gShine:'rgba(255,255,255,0.95)',acc:'#0c0c12'}
}

const dI=['graphite','aurum','argent','carbon','titanium']
const lI=['ivory','frost','silk','mist','porcelain']
const darkThemes=dI.map(id=>({id,pv:{background:`linear-gradient(135deg,${T[id].bg},${T[id].cBg})`},dot:id==='aurum'?'#c9a96e':id==='argent'?'#a8b0c8':null}))
const lightThemes=lI.map(id=>({id,pv:{background:`linear-gradient(135deg,${T[id].bg},${T[id].pP})`},dot:null}))

const themeVars=computed(()=>{const t=T[curTheme.value]||T.graphite;return{'--bg':t.bg,'--text':t.text,'--card-bg':t.cBg,'--pill-price':t.pP,'--pill-meta':t.pM,'--pill-name':t.pN,'--pill-search':t.pS,'--border':t.brd,'--card-border':t.brd,'--dim':t.dim,'--hover-bg':t.hBg,'--sticky-bg':t.sBg,'--seg-bg':t.seBg,'--seg-active':t.seA,'--seg-txt':t.seT,'--seg-txt-active':t.seTA,'--btn-bg':t.bBg,'--btn-brd':t.bBrd,'--liquid-bg':t.lBg,'--liquid-brd':t.lBrd,'--aura-text':t.aura,'--panel-bg':t.panBg,'--glass-base':t.gBase,'--glass-brd':t.gBrd,'--glass-shine':t.gShine,'--accent':t.acc,'--p-cols':activePriceCount.value}})
const pVars=computed(()=>{const t=T[curTheme.value]||T.graphite;return{'--panel-bg':t.panBg,'--border':t.brd,'--text':t.text,'--dim':t.dim,'--seg-bg':t.seBg,'--seg-active':t.seA,'--seg-txt':t.seT,'--seg-txt-active':t.seTA,'--bg':t.bg,color:t.text}})
const accentColor=computed(()=>(T[curTheme.value]||T.graphite).acc)

watch(curTheme,v=>{localStorage.setItem('bahur-theme',v)})
const selTheme=id=>{curTheme.value=id}

// ── Data ──
const loading=ref(true),errorMsg=ref(null),products=ref([]),showDash=ref(false),statsMode=ref('6m')
const toggleStatsMode=()=>{statsMode.value=statsMode.value==='6m'?'all':'6m'}

// ── Filters ──
const selectedBrands=ref([]),tempBrandInput=ref(''),showBrandMenu=ref(false)
const selectedFrags=ref([]),tempFragInput=ref(''),showFragMenu=ref(false)
const showFilters=ref(false),showNewMenu=ref(false)
const filterPlus=ref(false),filterStar=ref(false),showOut=ref(false)
const activeGender=ref('ВСЕ'),activeQuality=ref('ВСЕ'),sortBy=ref('id'),activeFactory=ref('ВСЕ')
const autoHighlightId=ref(null)
let hlI=null

const showPrices=ref({p50:true,p500:true,p1000:true}),priceLabels={p50:'50г',p500:'500г',p1000:'1кг'}
const activePriceCount=computed(()=>Object.values(showPrices.value).filter(Boolean).length)
const cardSize=ref('m')
const sizeOptions=[{label:'S',val:'s'},{label:'M',val:'m'},{label:'L',val:'l'}]

const anyMenuOpen=computed(()=>showBrandMenu.value||showFragMenu.value||showNewMenu.value||showFilters.value||showThemeMenu.value)
const genderOptions=[{label:'ВСЕ',val:'ВСЕ'},{label:'МУЖ',val:'m'},{label:'ЖЕН',val:'w'},{label:'УНИ',val:'y'}]
const factoryOptions=[{label:'ВСЕ',val:'ВСЕ'},{label:'LUZI',val:'LUZI'},{label:'EPS',val:'EPS'},{label:'SELUZ',val:'SELUZ'}]
const qualityOptions=[{label:'ВСЕ',val:'ВСЕ'},{label:'TOP',val:'TOP'},{label:'Q1',val:'Q1'},{label:'Q2',val:'Q2'}]
const sortOptions=[{label:'ID',val:'id'},{label:'ЦЕНА',val:'asc'},{label:'ЦЕНА',val:'desc'}]
const togglePrice=k=>{if(showPrices.value[k]&&Object.values(showPrices.value).filter(Boolean).length===1)return;showPrices.value[k]=!showPrices.value[k]}

// ── Menus ──
const brandBtnRef=ref(null),fragBtnRef=ref(null),statusBtnRef=ref(null),filterBtnRef=ref(null)
const brandMenuStyle=ref({}),fragMenuStyle=ref({}),statusMenuStyle=ref({}),filterMenuStyle=ref({})

function calcP(r,pw=280){const el=r?.value;if(!el)return{};const b=el.getBoundingClientRect(),vw=window.innerWidth;if(vw<=900)return{position:'fixed',top:(b.bottom+6)+'px',left:'12px',width:(vw-24)+'px',zIndex:9999};let l=b.left+b.width/2-pw/2;if(l+pw>vw-12)l=vw-pw-12;if(l<12)l=12;return{position:'fixed',top:(b.bottom+6)+'px',left:l+'px',width:pw+'px',zIndex:9999}}
const recP=()=>{if(showBrandMenu.value)brandMenuStyle.value=calcP(brandBtnRef);if(showFragMenu.value)fragMenuStyle.value=calcP(fragBtnRef);if(showNewMenu.value)statusMenuStyle.value=calcP(statusBtnRef);if(showFilters.value)filterMenuStyle.value=calcP(filterBtnRef);if(showThemeMenu.value)themeMenuStyle.value=calcP(themeBtnRef,260)}

const closeAllMenus=()=>{showBrandMenu.value=false;showFragMenu.value=false;showNewMenu.value=false;showFilters.value=false;showThemeMenu.value=false}
const toggleThemeMenu=async()=>{if(showThemeMenu.value){closeAllMenus();return}closeAllMenus();await nextTick();themeMenuStyle.value=calcP(themeBtnRef,260);showThemeMenu.value=true}
const toggleBrandMenu=async()=>{if(showBrandMenu.value){closeAllMenus();return}closeAllMenus();tempBrandInput.value='';await nextTick();brandMenuStyle.value=calcP(brandBtnRef);showBrandMenu.value=true}
const toggleFragMenu=async()=>{if(showFragMenu.value){closeAllMenus();return}closeAllMenus();tempFragInput.value='';await nextTick();fragMenuStyle.value=calcP(fragBtnRef);showFragMenu.value=true}
const toggleNewMenu=async()=>{if(showNewMenu.value){closeAllMenus();return}closeAllMenus();await nextTick();statusMenuStyle.value=calcP(statusBtnRef);showNewMenu.value=true}
const toggleFilterMenu=async()=>{if(showFilters.value){closeAllMenus();return}closeAllMenus();await nextTick();filterMenuStyle.value=calcP(filterBtnRef);showFilters.value=true}

const toggleBrandSelection=b=>{const i=selectedBrands.value.indexOf(b);i===-1?selectedBrands.value.push(b):selectedBrands.value.splice(i,1);closeAllMenus()}
const clearBrands=()=>{selectedBrands.value=[];closeAllMenus()}
const brandLabel=computed(()=>{const n=selectedBrands.value.length;return n===0?'БРЕНДЫ':`${n} БРЕНД${n>1?'А':''}`})

const toggleFragSelection=f=>{const i=selectedFrags.value.indexOf(f);i===-1?selectedFrags.value.push(f):selectedFrags.value.splice(i,1);closeAllMenus()}
const clearFrags=()=>{selectedFrags.value=[];closeAllMenus()}
const fragLabel=computed(()=>{const n=selectedFrags.value.length;return n===0?'АРОМАТЫ':`${n} АРОМАТ${n>1?'А':''}`})

const psg=computed(()=>({gridTemplateColumns:`repeat(${activePriceCount.value},1fr)`}))

// ── Scroll ──
const scrollTrack=ref(null),thumbTop=ref(0),thumbHeight=ref(10)
const updateThumb=()=>{const wH=window.innerHeight,dH=document.documentElement.scrollHeight,sY=window.scrollY;thumbHeight.value=Math.max((wH/dH)*100,5);const mx=dH-wH;thumbTop.value=mx<=0?0:(sY/mx)*(100-thumbHeight.value)}
const handleDrag=y=>{const tr=scrollTrack.value;if(!tr)return;const r=tr.getBoundingClientRect();const p=Math.min(Math.max((y-r.top)/r.height,0),1);window.scrollTo({top:p*(document.documentElement.scrollHeight-window.innerHeight),behavior:'auto'})}
let isDragging=false
const startDrag=e=>{isDragging=true;handleDrag(e.touches?e.touches[0].clientY:e.clientY);window.addEventListener('mousemove',onMM);window.addEventListener('touchmove',onTM,{passive:false});window.addEventListener('mouseup',stopDrag);window.addEventListener('touchend',stopDrag)}
const onMM=e=>{if(isDragging)handleDrag(e.clientY)},onTM=e=>{if(isDragging){e.preventDefault();handleDrag(e.touches[0].clientY)}}
const stopDrag=()=>{isDragging=false;window.removeEventListener('mousemove',onMM);window.removeEventListener('touchmove',onTM);window.removeEventListener('mouseup',stopDrag);window.removeEventListener('touchend',stopDrag)}
const trackClick=e=>handleDrag(e.clientY)

// ── Data loading ──
const parseCSV=data=>{try{return data.split(/\r?\n/).filter(l=>l.trim()).map(row=>{const c=row.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/).map(x=>x.replace(/^"|"$/g,'').trim());if(!c[0]||isNaN(parseInt(c[0]))||!c[2])return null;const g=c[4]?c[4].toLowerCase().trim():'';const fG=(g==='m'||g==='м'||g.includes('муж'))?'m':(g==='w'||g==='ж'||g.includes('жен'))?'w':(g==='y'||g==='у'||g.includes('уни'))?'y':'';const st=c[10]?c[10].trim():'';return{id:c[0],link:c[1]||'',brand:c[2]||'',name:c[3]||'',gender:fG,factory:c[5]||'',quality:c[6]||'',p50:parseInt(c[7])||0,p500:parseInt(c[8])||0,p1000:parseInt(c[9])||0,status:st,hasPlus:st.includes('+'),hasStar:st.includes('*'),isOut:st.includes('-'),sales6m:parseFloat(c[11])||0,salesAll:parseFloat(c[12])||0}}).filter(Boolean)}catch{return[]}}
const loadData=async()=>{loading.value=true;errorMsg.value=null;try{const r=await fetch('https://docs.google.com/spreadsheets/d/e/2PACX-1vTtT4zLEY49maKt0VxanZWA2ORKO1h39Mc5wB-XcZclDTmWfroFxQNAPxomg3x0-w/pub?gid=1234145733&single=true&output=csv');if(!r.ok)throw new Error();products.value=parseCSV(await r.text());if(!products.value.length)throw new Error();startHL();setTimeout(()=>loading.value=false,1500)}catch{errorMsg.value='Не удалось подключиться к базе данных.';loading.value=false}}
const startHL=()=>{if(hlI)clearInterval(hlI);hlI=setInterval(()=>{const list=sortedProducts.value;if(list.length){const p=list[Math.floor(Math.random()*list.length)];if(p){autoHighlightId.value=p.id;setTimeout(()=>{autoHighlightId.value=null},2000)}}},5000)}

// ── Computed data ──
const uniqueBrands=computed(()=>{const s=new Set();products.value.forEach(p=>p.brand&&s.add(p.brand));return Array.from(s).sort()})
const filteredBrandsDropdown=computed(()=>{const q=tempBrandInput.value.toLowerCase();return q?uniqueBrands.value.filter(b=>b.toLowerCase().includes(q)):uniqueBrands.value})
const uniqueFrags=computed(()=>{const s=new Set();products.value.forEach(p=>p.name&&s.add(p.name));return Array.from(s).sort()})
const filteredFragsDropdown=computed(()=>{const q=tempFragInput.value.toLowerCase();return q?uniqueFrags.value.filter(f=>f.toLowerCase().includes(q)):uniqueFrags.value})

const filteredProducts=computed(()=>products.value.filter(p=>{
  if(selectedBrands.value.length&&!selectedBrands.value.includes(p.brand))return false
  if(selectedFrags.value.length&&!selectedFrags.value.includes(p.name))return false
  if(activeGender.value!=='ВСЕ'&&p.gender!==activeGender.value)return false
  if(activeQuality.value!=='ВСЕ'&&p.quality!==activeQuality.value)return false
  if(activeFactory.value!=='ВСЕ'&&!p.factory.toUpperCase().includes(activeFactory.value))return false
  if(filterPlus.value&&!p.hasPlus)return false
  if(filterStar.value&&!p.hasStar)return false
  if(!showOut.value&&p.isOut)return false
  return true
}))
const sortedProducts=computed(()=>{const l=[...filteredProducts.value];if(sortBy.value==='asc')l.sort((a,b)=>a.p1000-b.p1000);else if(sortBy.value==='desc')l.sort((a,b)=>b.p1000-a.p1000);else l.sort((a,b)=>a.id-b.id);return l})
const stats=computed(()=>{const all=products.value.filter(p=>{if(selectedBrands.value.length&&!selectedBrands.value.includes(p.brand))return false;if(selectedFrags.value.length&&!selectedFrags.value.includes(p.name))return false;if(activeGender.value!=='ВСЕ'&&p.gender!==activeGender.value)return false;if(activeQuality.value!=='ВСЕ'&&p.quality!==activeQuality.value)return false;if(activeFactory.value!=='ВСЕ'&&!p.factory.toUpperCase().includes(activeFactory.value))return false;if(filterPlus.value&&!p.hasPlus)return false;if(filterStar.value&&!p.hasStar)return false;return true});const n=all.length||1;let s50=0,s500=0,s1000=0,av=0,ou=0;const ql={TOP:0,Q1:0,Q2:0},fc={LUZI:0,EPS:0,SELUZ:0};all.forEach(i=>{if(ql[i.quality]!==undefined)ql[i.quality]++;if(!i.isOut)av++;else ou++;s50+=i.p50;s500+=i.p500;s1000+=i.p1000;const f=i.factory.toUpperCase();if(f.includes('LUZI'))fc.LUZI++;else if(f.includes('EPS'))fc.EPS++;else if(f.includes('SELUZ'))fc.SELUZ++});const tl=[...all].sort((a,b)=>statsMode.value==='6m'?b.sales6m-a.sales6m:b.salesAll-a.salesAll).slice(0,50);return{total:all.length,countAvail:av,countOut:ou,availability:Math.round(av/n*100),avg50:Math.round(s50/n),avg500:Math.round(s500/n),avg1000:Math.round(s1000/n),qualityPerc:{TOP:Math.round(ql.TOP/n*100),Q1:Math.round(ql.Q1/n*100),Q2:Math.round(ql.Q2/n*100)},factoryPerc:{LUZI:Math.round(fc.LUZI/n*100),EPS:Math.round(fc.EPS/n*100),SELUZ:Math.round(fc.SELUZ/n*100)},topListFull:tl}})
const getSex=g=>({m:'МУЖ',w:'ЖЕН',y:'УНИ'}[g]||'—')
const openLink=u=>window.open(u.startsWith('http')?u:`https://${u}`,'_blank')

onMounted(()=>{const s=document.createElement('style');s.id='bg';s.textContent='html::-webkit-scrollbar{display:none!important}html{scrollbar-width:none!important;-ms-overflow-style:none!important}';document.head.appendChild(s);let m=document.querySelector('meta[name=viewport]');if(!m){m=document.createElement('meta');m.name='viewport';document.head.appendChild(m)}m.content='width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no';loadData();window.addEventListener('scroll',updateThumb);window.addEventListener('resize',updateThumb);window.addEventListener('resize',recP)})
onUnmounted(()=>{if(hlI)clearInterval(hlI);window.removeEventListener('scroll',updateThumb);window.removeEventListener('resize',updateThumb);window.removeEventListener('resize',recP)})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap');
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@300;400;700&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Kollektif&display=swap');

*{box-sizing:border-box}.main-font{font-family:'Nunito',sans-serif}.kollektif{font-family:'Kollektif','Nunito',sans-serif}.mono{font-family:'JetBrains Mono',monospace}.fw7{font-weight:700}.fw8{font-weight:800}.center{display:flex;align-items:center;justify-content:center}
.bahur-terminal{min-height:100vh;background:var(--bg);color:var(--text);font-family:'Nunito',sans-serif;touch-action:pan-y;transition:background .3s,color .3s}
::-webkit-scrollbar{width:2px;height:2px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:rgba(128,128,128,.25);border-radius:2px}
.container{max-width:1400px;margin:0 auto;padding:12px;overflow-x:hidden}

/* Glass pill */
.glass-pill{position:relative;background:var(--glass-base);border:1px solid var(--glass-brd);border-radius:20px;padding:0;cursor:pointer;overflow:hidden;backdrop-filter:blur(12px) saturate(1.2);-webkit-backdrop-filter:blur(12px) saturate(1.2);transition:all .2s}
.glass-pill::before{content:'';position:absolute;inset:0;border-radius:inherit;background:linear-gradient(135deg,var(--glass-shine) 0%,transparent 50%);opacity:.5;pointer-events:none}
.glass-pill:hover{transform:translateY(-1px);box-shadow:0 4px 16px rgba(0,0,0,.15)}
.glass-pill.active{background:var(--text);border-color:transparent}.glass-pill.active .gpt{color:var(--bg)}
.gpi{position:relative;z-index:1;display:flex;align-items:center;gap:4px;padding:7px 14px}
.gpt{font-size:10px;font-weight:800;letter-spacing:.8px;color:var(--text)}
.glass-pill.compact .gpi{padding:5px 10px}.glass-pill.compact .gpt{font-size:9px}

/* Filter pill special style */
.filter-pill{border-radius:10px}
.filter-pill .gpi{padding:5px 10px}

/* Header */
.header-bar{display:flex;justify-content:space-between;align-items:center;padding:6px 0;gap:10px;margin-bottom:4px}
.logo{font-size:20px;font-weight:900;letter-spacing:4px;color:var(--text);text-shadow:0 0 20px currentColor;flex:1;text-align:center;user-select:none}

/* Loading */
.lo{position:fixed;inset:0;background:#000;z-index:9999;display:flex;justify-content:center;align-items:center;overflow:hidden}
.lo-bg{position:absolute;inset:0;background:repeating-linear-gradient(45deg,transparent,transparent 10px,rgba(255,255,255,.3) 10px,rgba(255,255,255,.3) 13px);background-size:200% 200%;animation:bgm 4s linear infinite}
@keyframes bgm{to{background-position:100% 100%}}
.lo-c{position:relative;z-index:10}.lo-t{font-weight:800;font-size:60px;color:#fff;letter-spacing:8px;opacity:0;animation:si 1.5s cubic-bezier(.2,.8,.2,1) forwards}
@keyframes si{0%{transform:scale(.8);opacity:0;filter:blur(10px)}100%{transform:scale(1);opacity:1;filter:blur(0)}}
.ez{display:flex;justify-content:center;align-items:center;height:50vh}.eb{text-align:center;border:1px solid var(--border);padding:40px 60px;border-radius:4px;background:var(--bg)}

/* Dashboard */
.dw{display:grid;grid-template-rows:0fr;transition:grid-template-rows .3s ease}.dw.open{grid-template-rows:1fr;margin-bottom:8px}.dc{overflow:hidden}
.dg{display:grid;grid-template-columns:repeat(5,1fr);gap:6px}
.sc{border:1px solid var(--border);padding:10px 12px;background:var(--card-bg);border-left:2px solid var(--accent);border-radius:8px;transition:background .3s,border-color .3s}
.sw2{grid-column:span 5}.sl{display:block;font-size:8px;font-weight:800;color:var(--dim);margin-bottom:6px;letter-spacing:1.2px;text-transform:uppercase}
.sv{font-size:16px;font-weight:800}.ss{display:flex;gap:8px;margin-top:4px;font-size:9px;color:var(--dim);font-weight:700}.ss b{color:var(--text);margin-left:2px}
.sp2{display:flex;flex-direction:column;gap:1px}.sp3{font-size:10px;color:var(--dim);font-weight:700}.sp3 span{color:var(--accent);font-weight:800;margin-left:3px}
.br{margin-bottom:4px}.bm{display:flex;justify-content:space-between;font-size:8px;font-weight:700;margin-bottom:2px;text-transform:uppercase}
.bn{height:2px;background:var(--border);border-radius:1px;overflow:hidden}.bt{height:4px;background:var(--border);border-radius:2px;overflow:hidden;margin-top:6px}
.bf{height:100%;background:var(--accent);transition:background .3s}
.tsw{background:transparent;border:1px solid var(--border);color:var(--text);padding:3px 10px;border-radius:16px;font-size:9px;font-weight:700;cursor:pointer}
.tsc{max-height:100px;overflow-y:auto;display:flex;flex-direction:column;gap:2px;scrollbar-width:thin;scrollbar-color:rgba(128,128,128,.3) transparent}
.tsc::-webkit-scrollbar{width:2px}.tsc::-webkit-scrollbar-thumb{background:rgba(128,128,128,.4);border-radius:1px}
.tr2{display:grid;grid-template-columns:minmax(0,2fr) auto minmax(0,1fr);align-items:center;gap:6px;padding:2px 0;border-bottom:1px solid var(--border)}.tr2:last-child{border-bottom:none}
.tl{display:flex;align-items:center;min-width:0;overflow:hidden}.tn{color:var(--dim);margin-right:3px;font-weight:700;font-size:9px}
.tname{overflow:hidden;white-space:nowrap;text-overflow:ellipsis;font-weight:700;font-size:10px;text-transform:uppercase}
.tb2{display:flex;gap:2px}.tbd{border:1px solid var(--border);padding:1px 4px;font-size:7px;border-radius:3px;font-weight:700;text-transform:uppercase}.tbh{background:var(--pill-meta);border-color:transparent;font-weight:800}

/* Sticky nav */
.sn{position:sticky;top:0;z-index:100;background:var(--sticky-bg);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);box-shadow:0 4px 24px rgba(0,0,0,.3),0 1px 0 var(--border);border-radius:0 0 16px 16px;overflow:visible;padding:0 6px;transition:background .3s}
.ni{padding:6px 0 4px}
.ntr{display:flex;align-items:center;gap:5px}
.ntr-main{flex-wrap:wrap}
.nav-sep{width:1px;height:20px;background:var(--border);margin:0 2px;flex-shrink:0}

/* Popups */
.co{position:fixed;top:0;left:0;width:100vw;height:100vh;z-index:98;background:transparent}
.popup-teleport{background:var(--panel-bg);border:1px solid var(--border);border-radius:14px;padding:12px;box-shadow:0 20px 60px rgba(0,0,0,.7);display:flex;flex-direction:column;gap:8px;max-height:calc(100vh - 120px);overflow-y:auto;font-family:'Nunito',sans-serif;transition:background .3s,border-color .3s,color .3s}
.pop-enter-active,.pop-leave-active{transition:all .18s cubic-bezier(.16,1,.3,1)}.pop-enter-from,.pop-leave-to{opacity:0;transform:translateY(-6px) scale(.97)}
.dpop{min-width:200px;max-width:280px;gap:10px;padding:14px}
.drow{display:flex;gap:6px;justify-content:center}.dsep{height:1px;background:var(--border);margin:2px 0}
.sw{width:38px;height:38px;border-radius:10px;border:2px solid transparent;cursor:pointer;transition:all .2s;padding:0;flex-shrink:0;box-shadow:0 2px 8px rgba(0,0,0,.2);position:relative}
.sw:hover{border-color:rgba(128,128,128,.5);transform:scale(1.1)}
.sw.active{border-color:var(--text);box-shadow:0 0 0 2px var(--text),0 2px 12px rgba(0,0,0,.3)}
.sw-dot{position:absolute;bottom:3px;left:50%;transform:translateX(-50%);width:4px;height:4px;border-radius:50%}
.pinp{width:100%;background:var(--seg-bg);border:1px solid var(--border);padding:8px 10px;border-radius:8px;color:var(--text);font-size:11px;outline:none;font-weight:700;letter-spacing:.5px;transition:background .3s,color .3s}.pinp::placeholder{opacity:.5;color:var(--dim)}
.bsc{max-height:240px;overflow-y:auto;scrollbar-width:thin;scrollbar-color:rgba(128,128,128,.5) transparent;display:flex;flex-direction:column;gap:2px}
.bsc::-webkit-scrollbar{width:3px}.bsc::-webkit-scrollbar-thumb{background:rgba(128,128,128,.5);border-radius:2px}
.bbtn{display:flex;justify-content:space-between;align-items:center;background:transparent;color:var(--text);border:none;padding:8px 10px;border-radius:6px;cursor:pointer;font-size:11px;font-weight:700;width:100%;text-align:left;transition:background .12s;letter-spacing:.3px;gap:6px}
.bbtn:hover{background:rgba(128,128,128,.1)}
.ab{font-weight:800;border-bottom:1px solid var(--border);border-radius:0;margin-bottom:3px;padding-bottom:9px}
.btx{white-space:nowrap;overflow:hidden;text-overflow:ellipsis;text-transform:uppercase}
.tgr{display:flex;justify-content:space-between;align-items:center;cursor:pointer;padding:7px 0;border-bottom:1px solid var(--border);gap:8px}.tgr:last-child{border-bottom:none}
.tgl{font-size:10px;color:var(--text);font-weight:800;display:flex;align-items:center;gap:5px;letter-spacing:.7px}
.tg{width:32px;height:18px;border:1px solid var(--border);border-radius:18px;position:relative;flex-shrink:0;transition:border-color .3s}
.tgt{width:12px;height:12px;background:var(--text);border-radius:50%;position:absolute;left:2px;top:2px;transition:transform .3s,background .3s}
.tg.on .tgt{transform:translateX(14px)}
.ch{display:inline-flex;align-items:center;justify-content:center;width:16px;height:16px;border-radius:4px;font-size:11px;font-weight:900}
.chp{background:rgba(0,168,107,.2);color:#00a86b}.chs{background:rgba(160,32,240,.2);color:#a020f0}.chm{background:rgba(253,70,89,.2);color:#fd4659}
.ps{margin-bottom:2px}.pl{display:block;font-size:8px;font-weight:800;color:var(--dim);margin-bottom:4px;letter-spacing:1.2px}
.sg{display:flex;background:var(--seg-bg);padding:2px;border-radius:7px;transition:background .3s}
.sgb{flex:1;background:transparent;border:none;color:var(--seg-txt);padding:5px 0;font-size:9px;font-weight:800;border-radius:5px;cursor:pointer;transition:background .1s,color .1s;letter-spacing:.4px}
.sgb.active{background:var(--seg-active);color:var(--seg-txt-active);box-shadow:0 1px 4px rgba(0,0,0,.5)}

/* Table header — new 2-column brand/aroma layout */
.th{display:grid;grid-template-columns:.7fr 1fr repeat(3,52px) calc(var(--p-cols)*52px);align-items:stretch;padding:2px 0 4px}
.hn{padding:2px;display:flex;align-items:stretch}
.hpl{padding:2px;display:flex;align-items:stretch;justify-content:center}.hpr{display:grid;padding:2px;gap:3px}.hpr .hpl{padding:0}
.hp{display:flex;align-items:center;justify-content:center;width:100%;height:30px;border-radius:8px;font-size:8px;font-weight:800;letter-spacing:.8px;color:var(--dim);white-space:nowrap;transition:background .3s}
.mhp{background:var(--pill-meta)}.php{background:var(--pill-price)}
.nhp{background:var(--pill-search);justify-content:flex-start;padding-left:10px;font-size:9px;letter-spacing:1.2px}

/* Product grid */
.gt{display:flex;flex-direction:column;gap:4px;width:100%;min-width:700px;padding-top:4px}
.row{display:grid;grid-template-columns:.7fr 1fr repeat(3,52px) calc(var(--p-cols)*52px);align-items:stretch;width:100%;background:var(--card-bg);border:1px solid var(--card-border);border-radius:14px;position:relative;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,.1);transition:transform .18s,box-shadow .18s,background .3s;padding:3px}

/* Worn texture on cards */
.row::before{content:'';position:absolute;inset:0;border-radius:inherit;background:repeating-conic-gradient(rgba(128,128,128,.015) 0% 25%,transparent 0% 50%) 0 0/4px 4px;pointer-events:none;z-index:1;opacity:.8}
.row.cr:hover,.row.sh{transform:translateY(-1px);box-shadow:0 5px 18px rgba(0,0,0,.2);background:var(--hover-bg)}
.rc{display:contents}.cr{cursor:pointer}.out{opacity:.4;filter:grayscale(50%)}

/* Brand column */
.cn{display:flex;align-items:stretch;padding:2px}
.cbrand .pn{background:var(--pill-meta);border-radius:10px;padding:6px 8px;width:100%;display:flex;align-items:center;justify-content:center;min-height:34px;transition:background .3s}
.pn-brand .bc{font-size:10px;font-weight:800;opacity:.7;display:block;text-transform:uppercase;letter-spacing:1.2px;text-align:center}

/* Aroma column */
.caroma .pn{background:var(--pill-name);border-radius:10px;padding:6px 10px;width:100%;display:flex;flex-direction:column;justify-content:center;min-height:34px;transition:background .3s;position:relative}
.st2{font-weight:700;font-size:14px;line-height:1.2;text-transform:uppercase}

/* ID badge top-right */
.id-badge{position:absolute;top:4px;right:6px;font-size:8px;font-weight:900;color:var(--dim);opacity:.6;display:flex;align-items:center;gap:2px}
.id-st{font-size:10px;font-weight:900}

/* Meta pills (mobile) */
.mm{display:none;margin-top:4px;gap:3px;align-items:center;flex-wrap:wrap}
.mb{background:var(--pill-meta);border-radius:5px;padding:2px 5px;font-size:7px;font-weight:800;text-transform:uppercase;transition:background .3s}

/* Desktop meta columns */
.cm{display:flex;align-items:stretch;padding:2px}.do{}
.pm{background:var(--pill-meta);border-radius:8px;padding:0 3px;font-size:8px;font-weight:800;width:100%;height:100%;min-height:34px;display:flex;align-items:center;justify-content:center;transition:background .3s}

/* Prices */
.cp{display:grid;gap:3px;padding:2px;align-items:stretch}
.pp{background:var(--pill-price);border-radius:8px;padding:0 2px;font-size:10px;font-weight:800;width:100%;min-height:34px;display:flex;align-items:center;justify-content:center;transition:background .3s,color .3s}

/* Subtle dot at bottom center */
.row-dot{position:absolute;bottom:3px;left:50%;transform:translateX(-50%);width:3px;height:3px;border-radius:50%;background:var(--accent);opacity:0;transition:opacity .4s,transform .4s;z-index:2}
.row:hover .row-dot,.row.sh .row-dot{opacity:.5;transform:translateX(-50%) scale(1.5)}

/* Scroll track */
.strack{position:fixed;right:3px;top:15px;bottom:15px;width:14px;z-index:200;display:flex;justify-content:center;touch-action:none}
.sthumb{position:absolute;width:3px;background:var(--text);border-radius:2px;opacity:.2;transition:opacity .2s}
.strack:hover .sthumb{opacity:.5}
.strack::before{content:'';position:absolute;top:0;bottom:0;width:1px;background:var(--border)}
.tf{}

/* Card sizes */
.sz-s .row{padding:2px}.sz-s .pn{min-height:28px;padding:4px 6px}.sz-s .st2{font-size:11px}.sz-s .pn-brand .bc{font-size:8px}.sz-s .pp{min-height:28px;font-size:9px}.sz-s .pm{min-height:28px}.sz-s .hp{height:26px}
.sz-l .row{padding:4px}.sz-l .pn{min-height:44px;padding:8px 12px}.sz-l .st2{font-size:17px}.sz-l .pn-brand .bc{font-size:12px}.sz-l .pp{min-height:44px;font-size:12px}.sz-l .pm{min-height:44px}.sz-l .hp{height:38px}

@media(min-width:901px){.dg{grid-template-columns:repeat(5,1fr)}.sw2{grid-column:span 5}}
@media(max-width:900px){
  .strack{display:none!important}
  .dg{grid-template-columns:1fr 1fr}.sw2{grid-column:span 2}
  .sn{margin-left:-12px;margin-right:-12px;padding-left:12px;padding-right:12px;border-radius:0 0 14px 14px}
  .ntr{flex-wrap:wrap}
  .ntr-main{display:grid;grid-template-columns:1fr 1fr 1px 1fr 1fr;gap:5px}
  .nav-sep{width:100%;height:1px;margin:0}
  .glass-pill.compact{width:100%;justify-content:center}
  .glass-pill.compact .gpi{justify-content:center;width:100%}
  .gt{min-width:100%}
  .do{display:none!important}
  .mm{display:flex!important}
  .th,.row{grid-template-columns:.35fr .65fr calc(var(--p-cols)*36px)}
  .row{padding:2px;border-radius:10px}
  .cn{padding:1px}
  .cbrand .pn{padding:3px 4px;border-radius:7px;min-height:0}
  .pn-brand .bc{font-size:7px;letter-spacing:.5px}
  .caroma .pn{padding:4px 6px;border-radius:7px;min-height:0}
  .st2{font-size:10px}
  .id-badge{font-size:7px;top:2px;right:4px}
  .mm{margin-top:2px;gap:2px}.mb{padding:1px 4px;font-size:6px;border-radius:4px}
  .cp{padding:1px;gap:2px}.pp{font-size:9px;min-height:0;border-radius:6px}
  .hn{padding:1px}.nhp{padding-left:6px;font-size:7px;border-radius:7px;height:28px}
  .hpr{padding:1px;gap:2px}.hp{height:28px}
  .dpop{min-width:auto;max-width:calc(100vw - 24px)}.sw{width:42px;height:42px}
  .sz-s .st2{font-size:9px}.sz-l .st2{font-size:12px}
}
</style>
