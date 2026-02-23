
<template>
  <div class="bahur-terminal" :style="themeVars">
    <!-- SVG Liquid Glass Filter -->
    <svg style="position:absolute;width:0;height:0;overflow:hidden">
      <defs>
        <filter id="liquid-glass" x="-5%" y="-5%" width="110%" height="110%">
          <feTurbulence type="fractalNoise" :baseFrequency="lgNoise" numOctaves="2" seed="42" result="noise"/>
          <feGaussianBlur in="noise" stdDeviation="3" result="blurred"/>
          <feDisplacementMap in="SourceGraphic" in2="blurred" :scale="lgDistort" xChannelSelector="R" yChannelSelector="G"/>
        </filter>
      </defs>
    </svg>

    <div class="container">
      <!-- Loading -->
      <div v-if="loading" class="lo"><div class="lo-bg"></div><div class="lo-c"><span class="lo-t main-font">BAHUR</span></div></div>

      <!-- Error -->
      <div v-if="errorMsg" class="ez"><div class="eb"><div style="font-size:24px;margin-bottom:15px;opacity:.5">✕</div><h3 class="mono" style="font-size:13px;margin-bottom:10px;letter-spacing:1.5px">ОШИБКА</h3><p style="font-size:11px;color:var(--dim);margin-bottom:25px">{{ errorMsg }}</p><button @click="loadData" style="background:var(--text);border:none;color:var(--bg);padding:10px 24px;font-size:10px;cursor:pointer;font-weight:700;letter-spacing:1px;border-radius:6px" class="mono">ПОВТОРИТЬ</button></div></div>

      <div v-else-if="!loading">
        <!-- Overlay -->
        <div v-if="anyMenuOpen" class="co" @click="closeAllMenus"></div>

        <div class="tf">
          <!-- Sticky Header -->
          <div class="sn liquid-el" :style="lgStyle">
            <!-- Table header -->
            <div class="th" :class="'sz-'+cardSize">
              <div class="hn hid"><span class="hp nhp mono">#</span></div>
              <div class="hn hbrand" ref="brandBtnRef">
                <button @click="toggleBrandMenu" :class="['hp hdr-click kollektif',{active:showBrandMenu||selectedBrands.length>0}]">
                  <svg class="search-ico" viewBox="0 0 24 24"><path fill="currentColor" d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
                  <span>{{ brandLabel }}</span>
                </button>
              </div>
              <div class="hn haroma" ref="fragBtnRef">
                <button @click="toggleFragMenu" :class="['hp hdr-click kollektif',{active:showFragMenu||selectedFrags.length>0}]">
                  <svg class="search-ico" viewBox="0 0 24 24"><path fill="currentColor" d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
                  <span>{{ fragLabel }}</span>
                </button>
              </div>
              <div class="hpl do"><span class="hp mhp kollektif">ПОЛ</span></div>
              <div class="hpl do"><span class="hp mhp kollektif">ФАБРИКА</span></div>
              <div class="hpl do"><span class="hp mhp kollektif">КАЧЕСТВО</span></div>
              <div class="hpr" :style="psg"><div v-if="showPrices.p50" class="hpl"><span class="hp php mono">50г</span></div><div v-if="showPrices.p500" class="hpl"><span class="hp php mono">500г</span></div><div v-if="showPrices.p1000" class="hpl"><span class="hp php mono">1кг</span></div></div>
            </div>
          </div>

          <!-- Popups -->
          <teleport to="body">
            <transition name="pop"><div v-if="showBrandMenu" class="popup-teleport" :style="[brandMenuStyle,pVars]"><div style="width:100%"><input v-model="tempBrandInput" type="search" inputmode="search" enterkeyhint="search" placeholder="ПОИСК БРЕНДА…" class="pinp main-font"/></div><div class="bsc"><button @click="clearBrands" class="bbtn ab main-font"><svg style="width:14px;height:14px;flex-shrink:0" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12S6.5 22 12 22 22 17.5 22 12 17.5 2 12 2M10 17L5 12L6.41 10.59L10 14.17L17.59 6.58L19 8L10 17Z"/></svg><span>ВСЕ</span></button><button v-for="b in filteredBrandsDropdown" :key="b" @click="toggleBrandSelection(b)" class="bbtn main-font"><span class="btx">{{ b }}</span><svg v-if="selectedBrands.includes(b)" style="width:13px;height:13px" viewBox="0 0 24 24"><path fill="currentColor" d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"/></svg></button><div v-if="!filteredBrandsDropdown.length" style="font-size:10px;color:var(--dim);padding:6px 10px" class="main-font">НЕТ СОВПАДЕНИЙ</div></div></div></transition>
            <transition name="pop"><div v-if="showFragMenu" class="popup-teleport" :style="[fragMenuStyle,pVars]"><div style="width:100%"><input v-model="tempFragInput" type="search" inputmode="search" enterkeyhint="search" placeholder="ПОИСК АРОМАТА…" class="pinp main-font"/></div><div class="bsc"><button @click="clearFrags" class="bbtn ab main-font"><svg style="width:14px;height:14px;flex-shrink:0" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12S6.5 22 12 22 22 17.5 22 12 17.5 2 12 2M10 17L5 12L6.41 10.59L10 14.17L17.59 6.58L19 8L10 17Z"/></svg><span>ВСЕ</span></button><button v-for="f in filteredFragsDropdown" :key="f" @click="toggleFragSelection(f)" class="bbtn main-font"><span class="btx">{{ f }}</span><svg v-if="selectedFrags.includes(f)" style="width:13px;height:13px" viewBox="0 0 24 24"><path fill="currentColor" d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"/></svg></button><div v-if="!filteredFragsDropdown.length" style="font-size:10px;color:var(--dim);padding:6px 10px" class="main-font">НЕТ СОВПАДЕНИЙ</div></div></div></transition>

            <!-- Filters cascade -->
            <transition name="cascade">
              <div v-if="showFilters" class="filter-cascade" :style="pVars">
                <div class="fc-overlay" @click="showFilters=false"></div>
                <div class="fc-panel" ref="fcPanelRef" @touchstart="onPanelTouchStart" @touchmove="onPanelTouchMove" @touchend="onPanelTouchEnd">
                  <div class="fc-handle"></div>
                  <div class="fc-head"><span class="fc-title main-font">ФИЛЬТРЫ</span><button @click="showFilters=false" class="fc-close">✕</button></div>
                  <!-- Размер -->
                  <div class="ps">
                    <span class="pl main-font">РАЗМЕР</span>
                    <div class="sg">
                      <button @click="cardSize='s'" :class="['sgb main-font',{active:cardSize==='s'}]">
                        <svg width="12" height="12" viewBox="0 0 24 24"><path fill="currentColor" d="M19 13H5v-2h14v2z"/></svg>
                      </button>
                      <button @click="cardSize='m'" :class="['sgb main-font',{active:cardSize==='m'}]">
                        <svg width="14" height="14" viewBox="0 0 24 24"><path fill="currentColor" d="M4 8h4V4H4v4zm6 12h4v-4h-4v4zm-6 0h4v-4H4v4zm0-6h4v-4H4v4zm6 0h4v-4h-4v4zm6-10v4h4V4h-4zm-6 4h4V4h-4v4zm6 6h4v-4h-4v4zm0 6h4v-4h-4v4z"/></svg>
                      </button>
                      <button @click="cardSize='l'" :class="['sgb main-font',{active:cardSize==='l'}]">
                        <svg width="16" height="16" viewBox="0 0 24 24"><path fill="currentColor" d="M19 11H5v-2h14v2zm0 4H5v-2h14v2zm0 4H5v-2h14v2zm0-12H5V5h14v2z"/></svg>
                      </button>
                    </div>
                  </div>
                  <!-- Дизайн -->
                  <div class="ps">
                    <span class="pl main-font">ДИЗАЙН</span>
                    <div class="theme-toggle" @click="toggleTheme">
                      <span :class="['tt-label main-font',{active:curTheme==='graphite'}]">ТЁМНАЯ</span>
                      <div :class="['tt-track',{light:curTheme==='powder'}]"><div class="tt-thumb"></div></div>
                      <span :class="['tt-label main-font',{active:curTheme==='powder'}]">СВЕТЛАЯ</span>
                    </div>
                  </div>
                  <!-- Новинки -->
                  <div class="ps">
                    <span class="pl main-font">НОВИНКИ</span>
                    <div class="tgr" @click="filterPlus=!filterPlus"><span class="tgl main-font">НОВИНКИ <span class="ch chp">+</span></span><div :class="['tg',{on:filterPlus}]"><div class="tgt"></div></div></div>
                    <div class="tgr" @click="filterStar=!filterStar"><span class="tgl main-font">ВЕРСИИ <span class="ch chs">*</span></span><div :class="['tg',{on:filterStar}]"><div class="tgt"></div></div></div>
                    <div class="tgr" @click="showOut=!showOut"><span class="tgl main-font">НЕТ <span class="ch chm">-</span></span><div :class="['tg',{on:showOut}]"><div class="tgt"></div></div></div>
                  </div>
                  <!-- Пол -->
                  <div class="ps"><span class="pl main-font">ПОЛ</span><div class="sg"><button v-for="g in genderOptions" :key="g.val" @click="activeGender=g.val" :class="['sgb main-font',{active:activeGender===g.val}]">{{ g.label }}</button></div></div>
                  <!-- Фабрика -->
                  <div class="ps"><span class="pl main-font">ФАБРИКА</span><div class="sg"><button v-for="f in factoryOptions" :key="f.val" @click="activeFactory=f.val" :class="['sgb main-font',{active:activeFactory===f.val}]">{{ f.label }}</button></div></div>
                  <!-- Качество -->
                  <div class="ps"><span class="pl main-font">КАЧЕСТВО</span><div class="sg"><button v-for="q in qualityOptions" :key="q.val" @click="activeQuality=q.val" :class="['sgb main-font',{active:activeQuality===q.val}]">{{ q.label }}</button></div></div>
                  <!-- Цена -->
                  <div class="ps"><span class="pl main-font">СОРТИРОВКА</span><div class="sg"><button v-for="s in sortOptions" :key="s.val" @click="sortBy=s.val" :class="['sgb main-font',{active:sortBy===s.val}]"><span v-if="s.val==='id'">ID</span><span v-else>{{ s.label }}{{ s.val==='asc'?' ▲':' ▼' }}</span></button></div></div>
                  <!-- Столбцы -->
                  <div class="ps"><span class="pl main-font">СТОЛБЦЫ</span><div class="sg"><button v-for="(val,key) in priceLabels" :key="key" @click="togglePrice(key)" :class="['sgb main-font',{active:showPrices[key]}]">{{ val }}</button></div></div>
                </div>
              </div>
            </transition>

            <!-- Stats cascade -->
            <transition name="cascade">
              <div v-if="showDash" class="filter-cascade" :style="pVars">
                <div class="fc-overlay" @click="showDash=false"></div>
                <div class="fc-panel fc-stats" ref="statsPanelRef" @touchstart="onStatsTouchStart" @touchmove="onStatsTouchMove" @touchend="onStatsTouchEnd">
                  <div class="fc-handle"></div>
                  <!-- Sticky header inside stats -->
                  <div class="fc-head fc-head-sticky"><span class="fc-title main-font">СТАТИСТИКА</span><button @click="showDash=false" class="fc-close">✕</button></div>
                  <div class="stats-scroll">
                    <section class="dg">
                      <div class="sc"><label class="sl">АРОМАТЫ</label><div class="sv mono">{{ stats.total }}</div><div class="ss"><span>Есть: <b class="mono">{{ stats.countAvail }}</b></span><span>Нет: <b class="mono">{{ stats.countOut }}</b></span></div></div>
                      <div class="sc"><label class="sl">СКЛАД</label><div class="sv mono">{{ stats.availability }}%</div><div class="bt"><div class="bf" :style="{width:stats.availability+'%'}"></div></div></div>
                      <div class="sc"><label class="sl">СРЕДНЯЯ ЦЕНА</label><div class="sp2"><div v-if="showPrices.p50" class="sp3">50г: <span class="mono">{{ stats.avg50 }}₽</span></div><div v-if="showPrices.p500" class="sp3">500г: <span class="mono">{{ stats.avg500 }}₽</span></div><div v-if="showPrices.p1000" class="sp3">1кг: <span class="mono">{{ stats.avg1000 }}₽</span></div></div></div>
                      <div class="sc"><label class="sl">ФАБРИКИ</label><div v-for="f in ['LUZI','EPS','SELUZ']" :key="f" class="br2"><div class="br2-row"><span class="br2-name">{{ f }}</span><span class="br2-val">{{ stats.factoryPerc[f] }}%</span></div><div class="bn"><div class="bf" :style="{width:stats.factoryPerc[f]+'%'}"></div></div></div></div>
                      <div class="sc"><label class="sl">КАЧЕСТВО</label><div v-for="q in ['TOP','Q1','Q2']" :key="q" class="br2"><div class="br2-row"><span class="br2-name">{{ q }}</span><span class="br2-val">{{ stats.qualityPerc[q] }}%</span></div><div class="bn"><div class="bf" :style="{width:stats.qualityPerc[q]+'%'}"></div></div></div></div>
                      <div class="sc sw2">
                        <div class="rating-head"><span class="rating-label main-font">РЕЙТИНГ</span><div class="rating-sw"><button @click="statsMode='6m'" :class="['rsw-btn main-font',{active:statsMode==='6m'}]">6 МЕС</button><button @click="statsMode='all'" :class="['rsw-btn main-font',{active:statsMode==='all'}]">ВСЁ ВРЕМЯ</button></div></div>
                        <div class="tsc"><div v-for="(item,idx) in stats.topListFull" :key="idx" class="tr2">
                          <div class="tr2-top"><div class="tl"><span class="tn">{{ idx+1 }}.</span><span class="tname">{{ item.name }}</span></div><div class="tb2"><div class="tbd">{{ item.factory }}</div><div class="tbd">{{ item.quality }}</div><div class="tbd tbh">{{ statsMode==='6m'?item.sales6m:item.salesAll }}%</div></div></div>
                          <div class="bn"><div class="bf" :style="{width:(statsMode==='6m'?item.sales6m:item.salesAll)+'%'}"></div></div>
                        </div><div v-if="!stats.topListFull.length" style="font-size:10px;opacity:.5">НЕТ ДАННЫХ</div></div>
                      </div>
                    </section>
                  </div>
                </div>
              </div>
            </transition>
          </teleport>

          <!-- Products -->
          <div class="gt" :class="'sz-'+cardSize">
            <div v-for="(p,index) in sortedProducts" :key="p.id+'-'+index" :class="['row','cr',{out:p.isOut}]" @click="handleRowClick(p,$event)">
              <div class="rc">
                <div class="cn cid"><span class="id-num mono">{{ p.id }}<span v-if="p.isOut" class="id-st st-out">-</span><span v-else-if="p.hasPlus" class="id-st st-plus">+</span><span v-else-if="p.hasStar" class="id-st st-star">*</span></span></div>
                <div class="cn cbrand"><div class="pn pn-brand"><span class="bc kollektif">{{ p.brand }}</span></div></div>
                <div class="cn caroma"><div class="pn pn-aroma">
                  <span class="st2 kollektif">{{ p.name }}</span>
                  <div class="mm"><span class="mb kollektif">{{ getSex(p.gender) }}</span><span class="mb kollektif">{{ p.factory }}</span><span class="mb kollektif">{{ p.quality }}</span></div>
                </div></div>
                <div class="cm do center"><div class="pm kollektif">{{ getSex(p.gender) }}</div></div>
                <div class="cm do center"><div class="pm kollektif">{{ p.factory }}</div></div>
                <div class="cm do center"><div class="pm kollektif">{{ p.quality }}</div></div>
                <div class="cp" :style="psg">
                  <div v-if="showPrices.p50" class="pp mono">{{ p.p50 }}<span class="pp-cur">₽</span></div>
                  <div v-if="showPrices.p500" class="pp mono">{{ p.p500 }}<span class="pp-cur">₽</span></div>
                  <div v-if="showPrices.p1000" class="pp pp-main mono">{{ p.p1000 }}<span class="pp-cur">₽</span></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- FAB Pill: Stats + Filters -->
    <div v-if="!loading&&!errorMsg" class="fab-pill liquid-el" :style="lgStyle">
      <button @click="showDash=!showDash" :class="['fab-btn fab-stats',{active:showDash}]">
        <svg width="16" height="16" viewBox="0 0 24 24"><path fill="currentColor" d="M5 9.2h3V19H5zM10.6 5h2.8v14h-2.8zm5.6 8H19v6h-2.8z"/></svg>
      </button>
      <div class="fab-divider"></div>
      <button @click="showFilters=!showFilters" :class="['fab-btn fab-filt',{active:showFilters}]">
        <svg width="16" height="16" viewBox="0 0 24 24"><path fill="currentColor" d="M3 17v2h6v-2H3zM3 5v2h10V5H3zm10 16v-2h8v-2h-8v-2h-2v6h2zM7 9v2H3v2h4v2h2V9H7zm14 4v-2H11v2h10zm-6-4h2V7h4V5h-4V3h-2v6z"/></svg>
      </button>
    </div>

    <!-- Scroll Track -->
    <div v-if="!loading&&!errorMsg" class="strack" ref="scrollTrack" @mousedown.prevent="startDrag" @touchstart.prevent="startDrag" @click="trackClick"><div class="sthumb" :style="{top:thumbTop+'%',height:thumbHeight+'%'}"></div></div>
  </div>
</template>

<script setup>
import{ref,computed,onMounted,onUnmounted,nextTick,watch}from'vue'

// ── Liquid Glass ──
const lgBlur=ref(Number(localStorage.getItem('lg-blur'))||16)
const lgNoise=ref(Number(localStorage.getItem('lg-noise'))||0.012)
const lgDistort=ref(Number(localStorage.getItem('lg-distort'))||40)
const lgTint=ref(Number(localStorage.getItem('lg-tint'))||30)
const lgStyle=computed(()=>({'--lg-blur':lgBlur.value+'px','--lg-tint-opacity':lgTint.value/100}))
watch([lgBlur,lgNoise,lgDistort,lgTint],()=>{localStorage.setItem('lg-blur',lgBlur.value);localStorage.setItem('lg-noise',lgNoise.value);localStorage.setItem('lg-distort',lgDistort.value);localStorage.setItem('lg-tint',lgTint.value)})

// ── Themes ──
const saved=localStorage.getItem('bahur-theme')
const curTheme=ref(saved==='powder'?'powder':'graphite')

const T={
graphite:{bg:'#000000',text:'#e8e8e8',cBg:'rgba(255,255,255,0.03)',pP:'rgba(255,255,255,0.04)',pM:'rgba(255,255,255,0.04)',pN:'rgba(255,255,255,0.03)',brd:'rgba(255,255,255,0.06)',dim:'rgba(255,255,255,0.32)',hBg:'rgba(255,255,255,0.06)',sBg:'rgba(0,0,0,0.82)',seBg:'rgba(255,255,255,0.06)',seA:'#ffffff',seT:'rgba(255,255,255,0.35)',seTA:'#000000',panBg:'#0a0a0a',gBase:'rgba(255,255,255,0.02)',gBrd:'rgba(255,255,255,0.07)',gShine:'rgba(255,255,255,0.03)',acc:'rgba(255,255,255,0.55)',tRgb:'232,232,232',fabBg:'rgba(8,8,8,0.92)',fabBrd:'rgba(255,255,255,0.08)',barBg:'rgba(255,255,255,0.07)',barFill:'rgba(255,255,255,0.45)'},
powder:{bg:'#f5f5f5',text:'#0a0a0a',cBg:'rgba(255,255,255,0.7)',pP:'rgba(0,0,0,0.03)',pM:'rgba(0,0,0,0.03)',pN:'rgba(0,0,0,0.02)',brd:'rgba(0,0,0,0.06)',dim:'rgba(0,0,0,0.35)',hBg:'rgba(0,0,0,0.04)',sBg:'rgba(245,245,245,0.88)',seBg:'rgba(0,0,0,0.05)',seA:'#0a0a0a',seT:'rgba(0,0,0,0.35)',seTA:'#f5f5f5',panBg:'#ebebeb',gBase:'rgba(255,255,255,0.5)',gBrd:'rgba(0,0,0,0.06)',gShine:'rgba(255,255,255,0.7)',acc:'rgba(0,0,0,0.5)',tRgb:'10,10,10',fabBg:'rgba(240,240,240,0.92)',fabBrd:'rgba(0,0,0,0.06)',barBg:'rgba(0,0,0,0.06)',barFill:'rgba(0,0,0,0.3)'}
}

const themeVars=computed(()=>{const t=T[curTheme.value]||T.graphite;return{'--bg':t.bg,'--text':t.text,'--card-bg':t.cBg,'--pill-price':t.pP,'--pill-meta':t.pM,'--pill-name':t.pN,'--border':t.brd,'--card-border':t.brd,'--dim':t.dim,'--hover-bg':t.hBg,'--sticky-bg':t.sBg,'--seg-bg':t.seBg,'--seg-active':t.seA,'--seg-txt':t.seT,'--seg-txt-active':t.seTA,'--panel-bg':t.panBg,'--glass-base':t.gBase,'--glass-brd':t.gBrd,'--glass-shine':t.gShine,'--accent':t.acc,'--p-cols':activePriceCount.value,'--text-rgb':t.tRgb,'--fab-bg':t.fabBg,'--fab-brd':t.fabBrd,'--bar-bg':t.barBg,'--bar-fill':t.barFill}})
const pVars=computed(()=>{const t=T[curTheme.value]||T.graphite;return{'--panel-bg':t.panBg,'--border':t.brd,'--text':t.text,'--dim':t.dim,'--seg-bg':t.seBg,'--seg-active':t.seA,'--seg-txt':t.seT,'--seg-txt-active':t.seTA,'--bg':t.bg,'--card-bg':t.cBg,'--text-rgb':t.tRgb,'--bar-bg':t.barBg,'--bar-fill':t.barFill,'--pill-meta':t.pM,'--accent':t.acc,color:t.text}})

const toggleTheme=()=>{curTheme.value=curTheme.value==='graphite'?'powder':'graphite'}
watch(curTheme,v=>{localStorage.setItem('bahur-theme',v)})

// ── Data ──
const loading=ref(true),errorMsg=ref(null),products=ref([]),showDash=ref(false),statsMode=ref('6m')
const toggleStatsMode=()=>{statsMode.value=statsMode.value==='6m'?'all':'6m'}

// ── Filters ──
const selectedBrands=ref([]),tempBrandInput=ref(''),showBrandMenu=ref(false)
const selectedFrags=ref([]),tempFragInput=ref(''),showFragMenu=ref(false)
const showFilters=ref(false)
const filterPlus=ref(false),filterStar=ref(false),showOut=ref(false)
const activeGender=ref('ВСЕ'),activeQuality=ref('ВСЕ'),sortBy=ref('id'),activeFactory=ref('ВСЕ')

const showPrices=ref({p50:true,p500:true,p1000:true}),priceLabels={p50:'50г',p500:'500г',p1000:'1кг'}
const activePriceCount=computed(()=>Object.values(showPrices.value).filter(Boolean).length)
const cardSize=ref('l')

const anyMenuOpen=computed(()=>showBrandMenu.value||showFragMenu.value)
const genderOptions=[{label:'ВСЕ',val:'ВСЕ'},{label:'МУЖ',val:'m'},{label:'ЖЕН',val:'w'},{label:'УНИ',val:'y'}]
const factoryOptions=[{label:'ВСЕ',val:'ВСЕ'},{label:'LUZI',val:'LUZI'},{label:'EPS',val:'EPS'},{label:'SELUZ',val:'SELUZ'}]
const qualityOptions=[{label:'ВСЕ',val:'ВСЕ'},{label:'TOP',val:'TOP'},{label:'Q1',val:'Q1'},{label:'Q2',val:'Q2'}]
const sortOptions=[{label:'ID',val:'id'},{label:'ЦЕНА',val:'asc'},{label:'ЦЕНА',val:'desc'}]
const togglePrice=k=>{if(showPrices.value[k]&&Object.values(showPrices.value).filter(Boolean).length===1)return;showPrices.value[k]=!showPrices.value[k]}

// ── Menus ──
const brandBtnRef=ref(null),fragBtnRef=ref(null)
const brandMenuStyle=ref({}),fragMenuStyle=ref({})

function calcP(r,pw=280){const el=r?.value;if(!el)return{};const b=el.getBoundingClientRect(),vw=window.innerWidth;if(vw<=900)return{position:'fixed',top:(b.bottom+6)+'px',left:'12px',width:(vw-24)+'px',zIndex:9999};let l=b.left+b.width/2-pw/2;if(l+pw>vw-12)l=vw-pw-12;if(l<12)l=12;return{position:'fixed',top:(b.bottom+6)+'px',left:l+'px',width:pw+'px',zIndex:9999}}
const recP=()=>{if(showBrandMenu.value)brandMenuStyle.value=calcP(brandBtnRef);if(showFragMenu.value)fragMenuStyle.value=calcP(fragBtnRef)}

const closeAllMenus=()=>{showBrandMenu.value=false;showFragMenu.value=false}
const toggleBrandMenu=async()=>{if(showBrandMenu.value){closeAllMenus();return}closeAllMenus();tempBrandInput.value='';await nextTick();brandMenuStyle.value=calcP(brandBtnRef);showBrandMenu.value=true}
const toggleFragMenu=async()=>{if(showFragMenu.value){closeAllMenus();return}closeAllMenus();tempFragInput.value='';await nextTick();fragMenuStyle.value=calcP(fragBtnRef);showFragMenu.value=true}

const toggleBrandSelection=b=>{const i=selectedBrands.value.indexOf(b);i===-1?selectedBrands.value.push(b):selectedBrands.value.splice(i,1);closeAllMenus()}
const clearBrands=()=>{selectedBrands.value=[];closeAllMenus()}
const brandLabel=computed(()=>{const n=selectedBrands.value.length;return n===0?'БРЕНД':`${n} БРЕНД${n>1?'А':''}`})

const toggleFragSelection=f=>{const i=selectedFrags.value.indexOf(f);i===-1?selectedFrags.value.push(f):selectedFrags.value.splice(i,1);closeAllMenus()}
const clearFrags=()=>{selectedFrags.value=[];closeAllMenus()}
const fragLabel=computed(()=>{const n=selectedFrags.value.length;return n===0?'АРОМАТ':`${n} АРОМАТ${n>1?'А':''}`})

const psg=computed(()=>({gridTemplateColumns:`repeat(${activePriceCount.value},1fr)`}))

// ── Row click — open link, remove highlight immediately ──
const handleRowClick=(p,e)=>{if(p.link&&p.link.length>5){openLink(p.link)}if(e.currentTarget){e.currentTarget.blur()}}

// ── Scroll ──
const scrollTrack=ref(null),thumbTop=ref(0),thumbHeight=ref(10)
const updateThumb=()=>{const wH=window.innerHeight,dH=document.documentElement.scrollHeight,sY=window.scrollY;thumbHeight.value=Math.max((wH/dH)*100,5);const mx=dH-wH;thumbTop.value=mx<=0?0:(sY/mx)*(100-thumbHeight.value)}
const handleDrag=y=>{const tr=scrollTrack.value;if(!tr)return;const r=tr.getBoundingClientRect();const p=Math.min(Math.max((y-r.top)/r.height,0),1);window.scrollTo({top:p*(document.documentElement.scrollHeight-window.innerHeight),behavior:'auto'})}
let isDragging=false
const startDrag=e=>{isDragging=true;handleDrag(e.touches?e.touches[0].clientY:e.clientY);window.addEventListener('mousemove',onMM);window.addEventListener('touchmove',onTM,{passive:false});window.addEventListener('mouseup',stopDrag);window.addEventListener('touchend',stopDrag)}
const onMM=e=>{if(isDragging)handleDrag(e.clientY)},onTM=e=>{if(isDragging){e.preventDefault();handleDrag(e.touches[0].clientY)}}
const stopDrag=()=>{isDragging=false;window.removeEventListener('mousemove',onMM);window.removeEventListener('touchmove',onTM);window.removeEventListener('mouseup',stopDrag);window.removeEventListener('touchend',stopDrag)}
const trackClick=e=>handleDrag(e.clientY)

// ── Swipe to dismiss panels ──
const fcPanelRef=ref(null),statsPanelRef=ref(null)
let panelTouchStartY=0,panelTouchDelta=0
const onPanelTouchStart=e=>{panelTouchStartY=e.touches[0].clientY;panelTouchDelta=0}
const onPanelTouchMove=e=>{const dy=e.touches[0].clientY-panelTouchStartY;panelTouchDelta=dy;if(dy>0&&fcPanelRef.value){fcPanelRef.value.style.transform=`translateY(${dy}px)`;fcPanelRef.value.style.transition='none'}}
const onPanelTouchEnd=()=>{if(fcPanelRef.value){fcPanelRef.value.style.transition='transform .3s cubic-bezier(.4,0,.2,1)';if(panelTouchDelta>80){showFilters.value=false}fcPanelRef.value.style.transform=''}}

let statsTouchStartY=0,statsTouchDelta=0
const onStatsTouchStart=e=>{statsTouchStartY=e.touches[0].clientY;statsTouchDelta=0}
const onStatsTouchMove=e=>{const dy=e.touches[0].clientY-statsTouchStartY;statsTouchDelta=dy;if(dy>0&&statsPanelRef.value){statsPanelRef.value.style.transform=`translateY(${dy}px)`;statsPanelRef.value.style.transition='none'}}
const onStatsTouchEnd=()=>{if(statsPanelRef.value){statsPanelRef.value.style.transition='transform .3s cubic-bezier(.4,0,.2,1)';if(statsTouchDelta>80){showDash.value=false}statsPanelRef.value.style.transform=''}}

// ── Data loading ──
const parseCSV=data=>{try{return data.split(/\r?\n/).filter(l=>l.trim()).map(row=>{const c=row.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/).map(x=>x.replace(/^"|"$/g,'').trim());if(!c[0]||isNaN(parseInt(c[0]))||!c[2])return null;const g=c[4]?c[4].toLowerCase().trim():'';const fG=(g==='m'||g==='м'||g.includes('муж'))?'m':(g==='w'||g==='ж'||g.includes('жен'))?'w':(g==='y'||g==='у'||g.includes('уни'))?'y':'';const st=c[10]?c[10].trim():'';return{id:c[0],link:c[1]||'',brand:c[2]||'',name:c[3]||'',gender:fG,factory:c[5]||'',quality:c[6]||'',p50:parseInt(c[7])||0,p500:parseInt(c[8])||0,p1000:parseInt(c[9])||0,status:st,hasPlus:st.includes('+'),hasStar:st.includes('*'),isOut:st.includes('-'),sales6m:parseFloat(c[11])||0,salesAll:parseFloat(c[12])||0}}).filter(Boolean)}catch{return[]}}
const loadData=async()=>{loading.value=true;errorMsg.value=null;try{const r=await fetch('https://docs.google.com/spreadsheets/d/e/2PACX-1vTtT4zLEY49maKt0VxanZWA2ORKO1h39Mc5wB-XcZclDTmWfroFxQNAPxomg3x0-w/pub?gid=1234145733&single=true&output=csv');if(!r.ok)throw new Error();products.value=parseCSV(await r.text());if(!products.value.length)throw new Error();setTimeout(()=>loading.value=false,1500)}catch{errorMsg.value='Не удалось подключиться к базе данных.';loading.value=false}}

// ── Computed ──
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
onUnmounted(()=>{window.removeEventListener('scroll',updateThumb);window.removeEventListener('resize',updateThumb);window.removeEventListener('resize',recP)})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@100..900&display=swap');
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@300;400;500;600;700&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Kollektif&display=swap');

/* ══════════════════════════════════════════
   PRICE2026 — NEO-SKEUOMORPHIC MONOCHROME
   Pure Black & White · Liquid Glass · 2026
   ══════════════════════════════════════════ */

*{box-sizing:border-box;-webkit-tap-highlight-color:transparent;outline:none;-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale}
*:focus,*:active{outline:none}
button:focus,button:active,input:focus{outline:none;box-shadow:none}
button{-webkit-tap-highlight-color:transparent}

/* ── Font classes ── */
.main-font{font-family:'Inter',system-ui,-apple-system,sans-serif}
.kollektif{font-family:'Kollektif','Inter',system-ui,sans-serif}
.mono{font-family:'JetBrains Mono',ui-monospace,monospace;font-feature-settings:'tnum' 1,'zero' 1}
.center{display:flex;align-items:center;justify-content:center}

/* ── Root ── */
.bahur-terminal{
  min-height:100vh;background:var(--bg);color:var(--text);
  font-family:'Inter',system-ui,-apple-system,sans-serif;
  touch-action:pan-y;
  transition:background .6s cubic-bezier(.22,1,.36,1),color .6s cubic-bezier(.22,1,.36,1);
  letter-spacing:-0.01em;
  line-height:1.5
}
::-webkit-scrollbar{width:0;height:0}

/* CRITICAL: no overflow-x:hidden here — it breaks position:sticky */
.container{max-width:1400px;margin:0 auto;padding:10px 12px}

/* ══ LIQUID GLASS ══ */
.liquid-el{position:relative;isolation:isolate}
.liquid-el::before{
  content:'';position:absolute;inset:0;z-index:0;border-radius:inherit;
  box-shadow:
    inset 0 1px 0 0 rgba(255,255,255,0.05),
    inset 0 -1px 0 0 rgba(0,0,0,0.1),
    inset 0 1px 20px -6px var(--glass-shine);
  background-color:var(--glass-base);
  pointer-events:none
}
.liquid-el::after{
  content:'';position:absolute;inset:0;z-index:-1;border-radius:inherit;
  backdrop-filter:blur(var(--lg-blur,20px)) saturate(1.4);
  -webkit-backdrop-filter:blur(var(--lg-blur,20px)) saturate(1.4);
  filter:url(#liquid-glass);-webkit-filter:url(#liquid-glass);
  isolation:isolate;pointer-events:none
}

/* ══ Loading Screen ══ */
.lo{position:fixed;inset:0;background:#000;z-index:9999;display:flex;justify-content:center;align-items:center;overflow:hidden}
.lo-bg{
  position:absolute;inset:0;
  background:repeating-linear-gradient(45deg,transparent,transparent 10px,rgba(255,255,255,.08) 10px,rgba(255,255,255,.08) 13px);
  background-size:200% 200%;
  animation:bgm 4s linear infinite
}
@keyframes bgm{to{background-position:100% 100%}}
.lo-c{position:relative;z-index:10}
.lo-t{
  font-weight:200;font-size:64px;color:#fff;
  letter-spacing:0.2em;opacity:0;
  animation:si 2s cubic-bezier(.22,1,.36,1) forwards;
  text-transform:uppercase
}
@keyframes si{
  0%{transform:scale(.9) translateY(8px);opacity:0;filter:blur(16px)}
  100%{transform:scale(1) translateY(0);opacity:1;filter:blur(0)}
}

/* ── Error ── */
.ez{display:flex;justify-content:center;align-items:center;height:50vh}
.eb{
  text-align:center;
  border:1px solid var(--border);
  padding:48px 64px;border-radius:16px;
  background:var(--card-bg);
  backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);
  box-shadow:0 8px 40px rgba(0,0,0,.15)
}

/* ══ Sticky Header ══ */
.sn{
  position:sticky;top:0;z-index:100;
  background:var(--sticky-bg);
  border-radius:16px;overflow:visible;
  padding:8px 10px 6px;
  transition:background .6s cubic-bezier(.22,1,.36,1);
  box-shadow:
    0 1px 0 0 var(--glass-brd) inset,
    0 8px 32px rgba(0,0,0,.25),
    0 2px 8px rgba(0,0,0,.15);
  border:1px solid var(--glass-brd)
}

/* ══ Dashboard Stats (cascade) ══ */
.fc-head-sticky{position:sticky;top:0;z-index:2;background:var(--panel-bg);padding-bottom:8px;margin-bottom:4px}
.stats-scroll{overflow-y:auto;flex:1;scrollbar-width:none;-webkit-overflow-scrolling:touch}
.stats-scroll::-webkit-scrollbar{width:0}
.fc-stats{overflow:hidden;display:flex;flex-direction:column}

.dg{display:grid;grid-template-columns:repeat(2,1fr);gap:6px}
.sc{
  border:1px solid var(--border);
  padding:14px 16px;
  background:var(--card-bg);
  backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);
  border-left:2px solid var(--accent);
  border-radius:12px;
  transition:transform .3s cubic-bezier(.22,1,.36,1),box-shadow .3s cubic-bezier(.22,1,.36,1);
  contain:layout style paint
}
.sc:hover{transform:translateY(-1px);box-shadow:0 4px 16px rgba(0,0,0,.08)}

.sw2{grid-column:span 2}
.sl{display:block;font-size:8px;font-weight:600;color:var(--dim);margin-bottom:6px;letter-spacing:0.12em;text-transform:uppercase}
.sv{font-size:18px;font-weight:700;letter-spacing:-0.02em}
.ss{display:flex;gap:10px;margin-top:6px;font-size:9px;color:var(--dim);font-weight:600}
.ss b{color:var(--text);margin-left:3px}
.sp2{display:flex;flex-direction:column;gap:2px}
.sp3{font-size:10px;color:var(--dim);font-weight:600}
.sp3 span{color:var(--accent);font-weight:700;margin-left:4px}

/* Factory / Quality rows */
.br2{margin-bottom:8px}.br2:last-child{margin-bottom:0}
.br2-row{display:flex;justify-content:space-between;align-items:center;margin-bottom:4px}
.br2-name{font-size:9px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;color:var(--text)}
.br2-val{
  font-size:10px;font-weight:700;color:var(--text);
  border:1px solid var(--border);border-radius:6px;
  padding:2px 8px;background:var(--card-bg)
}

/* Bars — refined with glow */
.bn{height:4px;background:var(--bar-bg);border-radius:4px;overflow:hidden;width:100%}
.bt{height:4px;background:var(--bar-bg);border-radius:4px;overflow:hidden;margin-top:6px}
.bf{
  height:100%;background:var(--bar-fill);border-radius:4px;
  transition:width .5s cubic-bezier(.22,1,.36,1);min-width:2px;
  box-shadow:0 0 8px rgba(var(--text-rgb),0.1)
}

/* Rating header */
.rating-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;gap:8px}
.rating-label{font-size:8px;font-weight:600;color:var(--dim);letter-spacing:0.12em}
.rating-sw{display:flex;background:var(--seg-bg);border-radius:10px;padding:3px}
.rsw-btn{
  background:transparent;border:none;color:var(--seg-txt);
  padding:6px 14px;font-size:8px;font-weight:700;letter-spacing:0.06em;
  border-radius:8px;cursor:pointer;
  transition:background .25s cubic-bezier(.22,1,.36,1),color .25s cubic-bezier(.22,1,.36,1),box-shadow .25s cubic-bezier(.22,1,.36,1);
  white-space:nowrap
}
.rsw-btn.active{background:var(--seg-active);color:var(--seg-txt-active);box-shadow:0 2px 8px rgba(0,0,0,.15)}

/* Rating list */
.tsc{display:flex;flex-direction:column;gap:0;scrollbar-width:none}
.tsc::-webkit-scrollbar{width:0}
.tr2{display:flex;flex-direction:column;gap:4px;padding:6px 0;border-bottom:1px solid var(--border);contain:layout style paint}
.tr2:last-child{border-bottom:none}
.tr2-top{display:flex;justify-content:space-between;align-items:center;gap:8px}
.tl{display:flex;align-items:center;min-width:0;overflow:hidden;flex:1}
.tn{color:var(--dim);margin-right:4px;font-weight:600;font-size:9px;flex-shrink:0}
.tname{overflow:hidden;white-space:nowrap;text-overflow:ellipsis;font-weight:700;font-size:10px;text-transform:uppercase;letter-spacing:0.02em}
.tb2{display:flex;gap:3px;flex-shrink:0}
.tbd{border:1px solid var(--border);padding:2px 6px;font-size:7px;border-radius:4px;font-weight:700;text-transform:uppercase}
.tbh{background:var(--pill-meta);border-color:transparent;font-weight:800}

/* ══ Table Header ══ */
.th{display:grid;grid-template-columns:22px minmax(0,.7fr) minmax(0,1fr) repeat(3,52px) calc(var(--p-cols)*52px);align-items:stretch;padding:0}
.hn{padding:2px;display:flex;align-items:stretch}
.hid{padding:2px;display:flex;align-items:center;justify-content:center}
.hid .hp{width:22px;font-size:7px;justify-content:center;padding:0}
.hpl{padding:2px;display:flex;align-items:stretch;justify-content:center}
.hpr{display:grid;padding:2px;gap:2px}.hpr .hpl{padding:0}
.hp{
  display:flex;align-items:center;justify-content:center;
  width:100%;height:30px;border-radius:8px;
  font-size:7px;font-weight:700;letter-spacing:0.08em;
  color:var(--accent);white-space:nowrap;
  transition:background .3s cubic-bezier(.22,1,.36,1),color .3s cubic-bezier(.22,1,.36,1);
  background:transparent
}
.mhp{background:var(--pill-meta)}
.php{background:var(--pill-price)}
.nhp{background:transparent;justify-content:center;font-size:8px;letter-spacing:0.1em}

/* Clickable header — brand/aroma */
.hdr-click{
  border:none;cursor:pointer;gap:6px;
  transition:background .25s cubic-bezier(.22,1,.36,1),color .25s cubic-bezier(.22,1,.36,1),box-shadow .25s cubic-bezier(.22,1,.36,1);
  background:var(--card-bg);color:var(--text);
  justify-content:flex-start;padding-left:10px;
  font-size:8px;letter-spacing:0.08em;font-weight:700;
  backdrop-filter:blur(8px);-webkit-backdrop-filter:blur(8px)
}
.hdr-click:hover{background:var(--hover-bg);color:var(--text)}
.hdr-click.active{background:var(--text);color:var(--bg);box-shadow:0 2px 12px rgba(var(--text-rgb),0.15)}
.hdr-click.active .search-ico{color:var(--bg)}
.search-ico{width:11px;height:11px;flex-shrink:0;opacity:.35;transition:opacity .25s cubic-bezier(.22,1,.36,1)}
.hdr-click:hover .search-ico{opacity:.6}

/* ══ FAB Pill ══ */
.fab-pill{
  position:fixed;bottom:24px;left:calc(50% + 8px);
  transform:translateX(-50%);z-index:150;
  display:flex;align-items:center;height:52px;
  border-radius:26px;
  border:1px solid var(--fab-brd);
  background:var(--fab-bg);
  backdrop-filter:blur(24px) saturate(1.3);-webkit-backdrop-filter:blur(24px) saturate(1.3);
  box-shadow:
    0 8px 32px rgba(0,0,0,.2),
    0 2px 8px rgba(0,0,0,.1),
    inset 0 1px 0 0 rgba(255,255,255,0.04);
  overflow:hidden;
  transition:transform .3s cubic-bezier(.22,1,.36,1),box-shadow .3s cubic-bezier(.22,1,.36,1)
}
.fab-pill:hover{transform:translateX(-50%) translateY(-1px);box-shadow:0 12px 40px rgba(0,0,0,.25),0 2px 8px rgba(0,0,0,.12),inset 0 1px 0 0 rgba(255,255,255,0.04)}
.fab-btn{
  display:flex;align-items:center;justify-content:center;
  width:52px;height:100%;background:transparent;
  border:none;cursor:pointer;color:var(--text);
  transition:background .25s cubic-bezier(.22,1,.36,1),opacity .25s cubic-bezier(.22,1,.36,1)
}
.fab-btn:hover{background:rgba(128,128,128,.08)}
.fab-btn.active{color:var(--text);opacity:1;background:rgba(128,128,128,.1)}
.fab-divider{width:1px;height:24px;background:var(--border);flex-shrink:0}

/* ══ Filters / Stats Cascade ══ */
.filter-cascade{position:fixed;inset:0;z-index:9000;display:flex;align-items:flex-end;justify-content:center}
.fc-overlay{
  position:absolute;inset:0;
  background:rgba(0,0,0,.5);
  backdrop-filter:blur(8px) saturate(1.2);-webkit-backdrop-filter:blur(8px) saturate(1.2)
}
.fc-panel{
  position:relative;z-index:1;width:100%;max-width:440px;
  max-height:80vh;overflow-y:auto;
  border-radius:24px 24px 0 0;padding:16px 20px 28px;
  display:flex;flex-direction:column;gap:14px;
  background:var(--panel-bg);
  border:1px solid var(--border);border-bottom:none;
  box-shadow:
    0 -12px 48px rgba(0,0,0,.2),
    0 -2px 8px rgba(0,0,0,.1),
    inset 0 1px 0 0 rgba(255,255,255,0.04);
  scrollbar-width:none
}
.fc-stats{max-height:85vh;overflow:hidden}
.fc-panel::-webkit-scrollbar{width:0}
.fc-handle{width:36px;height:4px;background:var(--dim);opacity:.25;border-radius:4px;margin:0 auto 6px}
.fc-head{display:flex;justify-content:space-between;align-items:center}
.fc-title{font-size:11px;font-weight:700;letter-spacing:0.15em;color:var(--dim)}
.fc-close{
  background:transparent;border:none;color:var(--dim);
  font-size:16px;cursor:pointer;padding:6px 8px;
  border-radius:8px;
  transition:color .25s cubic-bezier(.22,1,.36,1),background .25s cubic-bezier(.22,1,.36,1)
}
.fc-close:hover{color:var(--text);background:rgba(128,128,128,.08)}

/* Cascade transitions */
.cascade-enter-active,.cascade-enter-active .fc-panel,.cascade-enter-active .fc-overlay{transition:all .45s cubic-bezier(.22,1,.36,1)}
.cascade-leave-active,.cascade-leave-active .fc-panel,.cascade-leave-active .fc-overlay{transition:all .3s cubic-bezier(.55,0,1,.45)}
.cascade-enter-from .fc-panel,.cascade-leave-to .fc-panel{transform:translateY(100%)}
.cascade-enter-from .fc-overlay,.cascade-leave-to .fc-overlay{opacity:0}

/* ── Theme Toggle ── */
.theme-toggle{display:flex;align-items:center;gap:12px;justify-content:center;padding:8px 0;cursor:pointer;user-select:none}
.tt-label{font-size:9px;font-weight:700;letter-spacing:0.08em;color:var(--dim);transition:color .35s cubic-bezier(.22,1,.36,1)}
.tt-label.active{color:var(--text)}
.tt-track{
  width:48px;height:26px;border-radius:26px;
  background:var(--seg-bg);border:1px solid var(--border);
  position:relative;
  transition:background .35s cubic-bezier(.22,1,.36,1),border-color .35s cubic-bezier(.22,1,.36,1);
  flex-shrink:0
}
.tt-thumb{
  width:20px;height:20px;border-radius:50%;background:var(--text);
  position:absolute;left:2px;top:2px;
  transition:transform .4s cubic-bezier(.22,1,.36,1);
  box-shadow:0 2px 6px rgba(0,0,0,.2)
}
.tt-track.light .tt-thumb{transform:translateX(22px)}

/* ── Filter Sections ── */
.ps{padding:0}
.pl{display:block;font-size:8px;font-weight:600;color:var(--dim);margin-bottom:6px;letter-spacing:0.12em}
.sg{display:flex;background:var(--seg-bg);padding:3px;border-radius:10px;transition:background .4s cubic-bezier(.22,1,.36,1)}
.sgb{
  flex:1;background:transparent;border:none;color:var(--seg-txt);
  padding:7px 0;font-size:8px;font-weight:700;
  border-radius:8px;cursor:pointer;
  transition:background .25s cubic-bezier(.22,1,.36,1),color .25s cubic-bezier(.22,1,.36,1),box-shadow .25s cubic-bezier(.22,1,.36,1);
  letter-spacing:0.04em;
  display:flex;align-items:center;justify-content:center;gap:3px
}
.sgb.active{background:var(--seg-active);color:var(--seg-txt-active);box-shadow:0 2px 8px rgba(0,0,0,.15)}
.tgr{
  display:flex;justify-content:space-between;align-items:center;
  cursor:pointer;padding:8px 0;
  border-bottom:1px solid var(--border);gap:10px;
  transition:opacity .25s cubic-bezier(.22,1,.36,1)
}
.tgr:last-child{border-bottom:none}
.tgr:hover{opacity:.75}
.tgl{font-size:10px;color:var(--text);font-weight:700;display:flex;align-items:center;gap:6px;letter-spacing:0.04em}
.tg{
  width:32px;height:18px;border:1px solid var(--border);
  border-radius:18px;position:relative;flex-shrink:0;
  transition:background .3s cubic-bezier(.22,1,.36,1),border-color .3s cubic-bezier(.22,1,.36,1)
}
.tg.on{border-color:var(--accent)}
.tgt{
  width:12px;height:12px;background:var(--text);border-radius:50%;
  position:absolute;left:2px;top:2px;
  transition:transform .35s cubic-bezier(.22,1,.36,1);
  box-shadow:0 1px 4px rgba(0,0,0,.15)
}
.tg.on .tgt{transform:translateX(14px)}

/* Status indicator badges — MONOCHROME ONLY */
.ch{
  display:inline-flex;align-items:center;justify-content:center;
  width:16px;height:16px;border-radius:4px;font-size:10px;font-weight:900
}
.chp{background:rgba(76,175,80,.12);color:#4caf50}
.chs{background:rgba(156,39,176,.12);color:#ab47bc}
.chm{background:rgba(244,67,54,.12);color:#ef5350}

/* ── Popups ── */
.co{position:fixed;top:0;left:0;width:100vw;height:100vh;z-index:98;background:transparent}
.popup-teleport{
  background:var(--panel-bg);border:1px solid var(--border);
  border-radius:14px;padding:12px;
  box-shadow:0 20px 60px rgba(0,0,0,.3),0 4px 16px rgba(0,0,0,.15);
  backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);
  display:flex;flex-direction:column;gap:8px;
  max-height:calc(100vh - 120px);overflow-y:auto;
  font-family:'Inter',system-ui,sans-serif;
  transition:opacity .25s cubic-bezier(.22,1,.36,1),transform .25s cubic-bezier(.22,1,.36,1)
}
.pop-enter-active,.pop-leave-active{transition:opacity .2s cubic-bezier(.22,1,.36,1),transform .2s cubic-bezier(.22,1,.36,1)}
.pop-enter-from,.pop-leave-to{opacity:0;transform:translateY(-6px) scale(.97)}
.pinp{
  width:100%;background:var(--seg-bg);border:1px solid var(--border);
  padding:9px 12px;border-radius:10px;color:var(--text);
  font-size:11px;outline:none;font-weight:600;letter-spacing:0.04em;
  transition:border-color .3s cubic-bezier(.22,1,.36,1),box-shadow .3s cubic-bezier(.22,1,.36,1)
}
.pinp:focus{border-color:var(--accent);box-shadow:0 0 0 3px rgba(var(--text-rgb),0.05)}
.pinp::placeholder{opacity:.3;color:var(--dim)}
.bsc{max-height:240px;overflow-y:auto;scrollbar-width:none;display:flex;flex-direction:column;gap:1px}
.bsc::-webkit-scrollbar{width:0}
.bbtn{
  display:flex;justify-content:space-between;align-items:center;
  background:transparent;color:var(--text);border:none;
  padding:8px 10px;border-radius:8px;cursor:pointer;
  font-size:11px;font-weight:600;width:100%;text-align:left;
  transition:background .2s cubic-bezier(.22,1,.36,1);
  letter-spacing:0.02em;gap:8px
}
.bbtn:hover{background:rgba(128,128,128,.06)}
.ab{font-weight:700;border-bottom:1px solid var(--border);border-radius:0;margin-bottom:3px;padding-bottom:10px}
.btx{white-space:nowrap;overflow:hidden;text-overflow:ellipsis;text-transform:uppercase}

/* ══ Product Grid ══ */
.gt{
  display:flex;flex-direction:column;gap:3px;
  width:100%;min-width:700px;
  padding-top:6px;padding-bottom:90px;
  overflow-x:hidden
}
.row{
  display:grid;
  grid-template-columns:22px minmax(0,.7fr) minmax(0,1fr) repeat(3,52px) calc(var(--p-cols)*52px);
  align-items:stretch;width:100%;
  background:var(--card-bg);
  backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);
  border:1px solid var(--card-border);
  border-radius:12px;position:relative;overflow:hidden;
  transition:background .3s cubic-bezier(.22,1,.36,1),box-shadow .3s cubic-bezier(.22,1,.36,1),transform .3s cubic-bezier(.22,1,.36,1);
  padding:2px;
  contain:layout style paint
}
.row.cr:hover{
  box-shadow:0 4px 20px rgba(0,0,0,.1),0 1px 4px rgba(0,0,0,.06);
  background:var(--hover-bg);
  transform:translateY(-0.5px)
}
.row:focus,.row:active{outline:none;box-shadow:none;transform:none}
.row{-webkit-tap-highlight-color:transparent}
.row *{-webkit-tap-highlight-color:transparent}
.rc{display:contents}.cr{cursor:pointer}
.out{opacity:.25;filter:grayscale(100%)}

/* ID column */
.cid{display:flex;align-items:center;justify-content:center;padding:2px 0}
.id-num{font-size:7px;font-weight:500;color:var(--dim);opacity:.5;display:flex;align-items:center;gap:1px;line-height:1}
.id-st{font-size:8px;font-weight:800}

/* MONOCHROME status indicators — NO colors */
.st-out{color:#ef5350}
.st-plus{color:#4caf50}
.st-star{color:#ab47bc}

/* Brand — left-aligned */
.cn{display:flex;align-items:stretch;padding:1px}
.cbrand .pn{
  background:var(--pill-meta);border-radius:10px;
  padding:6px 10px;width:100%;display:flex;
  align-items:center;justify-content:flex-start;
  min-height:34px;
  transition:background .35s cubic-bezier(.22,1,.36,1)
}
.pn-brand .bc{font-size:10px;font-weight:700;display:block;text-transform:uppercase;letter-spacing:0.06em;text-align:left}

/* Brand-Aroma divider */
.cbrand{position:relative}
.cbrand::after{content:'';position:absolute;right:0;top:18%;bottom:18%;width:1px;background:var(--dim);opacity:.1}

/* Aroma */
.caroma .pn{
  background:var(--pill-name);border-radius:10px;
  padding:6px 10px;width:100%;display:flex;
  flex-direction:column;justify-content:center;
  min-height:34px;
  transition:background .35s cubic-bezier(.22,1,.36,1)
}
.st2{font-weight:700;font-size:10px;line-height:1.25;text-transform:uppercase;letter-spacing:0.06em}

/* Meta pills (mobile) */
.mm{display:none;margin-top:4px;gap:3px;align-items:center;flex-wrap:wrap}
.mb{
  background:var(--pill-meta);border-radius:5px;
  padding:2px 5px;font-size:6.5px;font-weight:700;
  text-transform:uppercase;letter-spacing:0.04em;
  transition:background .3s cubic-bezier(.22,1,.36,1)
}

/* Desktop meta */
.cm{display:flex;align-items:stretch;padding:1px}.do{}
.pm{
  background:var(--pill-meta);border-radius:8px;
  padding:0 4px;font-size:7px;font-weight:700;
  width:100%;height:100%;min-height:34px;
  display:flex;align-items:center;justify-content:center;
  transition:background .35s cubic-bezier(.22,1,.36,1);
  letter-spacing:0.04em
}

/* ══ Prices ══ */
.cp{display:grid;gap:2px;padding:1px;align-items:stretch}
.pp{
  background:var(--card-bg);border:1px solid var(--border);
  border-radius:8px;padding:0 4px;
  font-size:10px;font-weight:600;
  width:100%;min-height:34px;
  display:flex;align-items:center;justify-content:center;
  transition:background .35s cubic-bezier(.22,1,.36,1),border-color .35s cubic-bezier(.22,1,.36,1);
  color:var(--text);gap:0
}
.pp-main{font-weight:700;font-size:11px}
.pp-cur{font-size:7px;opacity:.3;margin-left:1px}

/* ── Scroll Track ── */
.strack{position:fixed;right:3px;top:15px;bottom:15px;width:14px;z-index:200;display:flex;justify-content:center;touch-action:none}
.sthumb{
  position:absolute;width:2px;background:var(--text);border-radius:2px;
  opacity:.1;transition:opacity .35s cubic-bezier(.22,1,.36,1)
}
.strack:hover .sthumb{opacity:.35}
.strack::before{content:'';position:absolute;top:0;bottom:0;width:1px;background:var(--border);opacity:.4}
.tf{}

/* ══ Card Sizes ══ */
/* Small */
.sz-s .row{padding:1px}
.sz-s .pn{min-height:28px;padding:4px 6px}
.sz-s .st2{font-size:8px}
.sz-s .pn-brand .bc{font-size:8px}
.sz-s .pp{min-height:28px;font-size:8px}
.sz-s .pm{min-height:28px}
.sz-s .hp{height:26px}

/* Large (default) */
.sz-l .th,.sz-l .row{grid-template-columns:24px minmax(0,.7fr) minmax(0,1fr) repeat(3,60px) calc(var(--p-cols)*56px)}
.sz-l .row{padding:3px}
.sz-l .pn{min-height:44px;padding:8px 12px}
.sz-l .st2{font-size:14px;letter-spacing:0.04em}
.sz-l .pn-brand .bc{font-size:13px;letter-spacing:0.06em}
.sz-l .pp{min-height:44px;font-size:12px}
.sz-l .pp-main{font-size:13px}
.sz-l .pm{min-height:44px;font-size:9px}
.sz-l .hp{height:36px}

/* ══ Responsive ══ */
@media(min-width:901px){
  .dg{grid-template-columns:repeat(3,1fr)}.sw2{grid-column:span 3}
  .fc-panel{max-width:600px}
  .fc-stats{max-width:680px}
}

@media(max-width:900px){
  .strack{display:none!important}
  .dg{grid-template-columns:1fr 1fr}.sw2{grid-column:span 2}
  .sn{margin-left:-12px;margin-right:-12px;padding-left:10px;padding-right:10px;border-radius:0 0 14px 14px}
  .gt{min-width:100%;overflow-x:hidden}
  .do{display:none!important}
  .mm{display:flex!important}
  .th,.row{grid-template-columns:20px minmax(0,.35fr) minmax(0,.65fr) calc(var(--p-cols)*36px)}
  .row{padding:1px;border-radius:10px}
  .cn{padding:1px}
  .cbrand .pn{padding:4px 5px;border-radius:8px;min-height:0}
  .pn-brand .bc{font-size:7.5px;letter-spacing:0.04em}
  .caroma .pn{padding:4px 6px;border-radius:8px;min-height:0}
  .st2{font-size:8.5px}
  .id-num{font-size:6px}
  .mm{margin-top:3px;gap:3px}.mb{padding:2px 4px;font-size:5.5px;border-radius:4px}
  .cp{padding:1px;gap:1px}.pp{font-size:8.5px;min-height:0;border-radius:6px}
  .hn{padding:1px}.nhp{font-size:7px;border-radius:8px;height:28px}
  .hdr-click{font-size:7.5px;padding-left:6px;height:28px;border-radius:8px}
  .hpr{padding:1px;gap:1px}.hp{height:28px}
  .fab-pill{bottom:16px;height:46px;border-radius:23px}
  .fab-btn{width:46px}
  .fab-divider{height:20px}
  .fc-panel{max-width:100%;border-radius:20px 20px 0 0;padding:12px 16px 24px}

  /* Size overrides for mobile */
  .sz-s .st2{font-size:7px}
  .sz-l .st2{font-size:11.5px}
  .sz-l .pn-brand .bc{font-size:9.5px}
  .sz-l .th,.sz-l .row{grid-template-columns:20px minmax(0,.35fr) minmax(0,.65fr) calc(var(--p-cols)*36px)}
  .sz-l .row{padding:2px}
  .sz-l .caroma .pn{padding:6px 7px}
  .sz-l .cbrand .pn,.sz-l .caroma .pn{min-height:40px}
}
</style>
