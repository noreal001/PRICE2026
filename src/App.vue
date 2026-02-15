
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
      <div v-if="errorMsg" class="ez"><div class="eb"><div style="font-size:30px;margin-bottom:15px;opacity:.8">✕</div><h3 class="mono" style="font-size:14px;margin-bottom:10px;letter-spacing:1px">ОШИБКА ПОДКЛЮЧЕНИЯ</h3><p style="font-size:12px;color:var(--dim);margin-bottom:25px">{{ errorMsg }}</p><button @click="loadData" style="background:var(--text);border:none;color:var(--bg);padding:12px 24px;font-size:11px;cursor:pointer;font-weight:700" class="mono">ПОВТОРИТЬ</button></div></div>

      <div v-else-if="!loading">
        <!-- Overlay for popups -->
        <div v-if="anyMenuOpen" class="co" @click="closeAllMenus"></div>

        <div class="tf">
          <!-- Sticky Header — card-like, liquid glass -->
          <div class="sn liquid-el" :style="lgStyle">
            <!-- Stats tab button (top-left corner) -->
            <button @click="showDash=!showDash" :class="['stats-tab mono',{active:showDash}]">📊</button>

            <!-- Table header row — БРЕНД and АРОМАТ are clickable search buttons -->
            <div class="th" :class="'sz-'+cardSize">
              <div class="hn hid"><span class="hp nhp mono">#</span></div>
              <div class="hn hbrand" ref="brandBtnRef">
                <button @click="toggleBrandMenu" :class="['hp nhp hdr-click kollektif',{active:showBrandMenu||selectedBrands.length>0}]">
                  <svg class="search-ico" viewBox="0 0 24 24"><path fill="currentColor" d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
                  <span>{{ brandLabel }}</span>
                </button>
              </div>
              <div class="hn haroma" ref="fragBtnRef">
                <button @click="toggleFragMenu" :class="['hp nhp hdr-click kollektif',{active:showFragMenu||selectedFrags.length>0}]">
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

          <!-- Size S/M/L — between header and table -->
          <div class="size-seg">
            <button v-for="sz in sizeOptions" :key="sz.val" @click="cardSize=sz.val" :class="['size-btn main-font',{active:cardSize===sz.val}]">{{ sz.label }}</button>
          </div>

          <!-- Dashboard (shows at top when stats tab clicked) -->
          <div :class="['dw',{open:showDash}]"><div class="dc"><section class="dg">
            <div class="sc"><label class="sl">АРОМАТЫ</label><div class="sv mono">{{ stats.total }}</div><div class="ss"><span>Есть: <b class="mono">{{ stats.countAvail }}</b></span><span>Нет: <b class="mono">{{ stats.countOut }}</b></span></div></div>
            <div class="sc"><label class="sl">СКЛАД</label><div class="sv mono">{{ stats.availability }}%</div><div class="bt"><div class="bf" :style="{width:stats.availability+'%'}"></div></div></div>
            <div class="sc"><label class="sl">СРЕДНЯЯ ЦЕНА</label><div class="sp2"><div v-if="showPrices.p50" class="sp3">50г: <span class="mono">{{ stats.avg50 }}₽</span></div><div v-if="showPrices.p500" class="sp3">500г: <span class="mono">{{ stats.avg500 }}₽</span></div><div v-if="showPrices.p1000" class="sp3">1кг: <span class="mono">{{ stats.avg1000 }}₽</span></div></div></div>
            <div class="sc sc-right"><label class="sl">ФАБРИКИ</label><div v-for="f in ['LUZI','EPS','SELUZ']" :key="f" class="br"><div class="bm"><span class="mono">{{ f }}</span><span class="mono">{{ stats.factoryPerc[f] }}%</span></div><div class="bn"><div class="bf" :style="{width:stats.factoryPerc[f]+'%'}"></div></div></div></div>
            <div class="sc sc-right"><label class="sl">КАЧЕСТВО</label><div v-for="q in ['TOP','Q1','Q2']" :key="q" class="br"><div class="bm"><span class="mono">{{ q }}</span><span class="mono">{{ stats.qualityPerc[q] }}%</span></div><div class="bn"><div class="bf" :style="{width:stats.qualityPerc[q]+'%'}"></div></div></div></div>
            <div class="sc sw2"><div style="display:flex;justify-content:center;margin-bottom:6px"><button @click="toggleStatsMode" class="tsw main-font"><span style="color:var(--dim)">РЕЙТИНГ:</span> {{ statsMode==='6m'?'6 МЕС':'ВСЕ ВРЕМЯ' }} ⇄</button></div><div class="tsc"><div v-for="(item,idx) in stats.topListFull" :key="idx" class="tr2"><div class="tl"><span class="tn mono">{{ idx+1 }}.</span><span class="tname kollektif">{{ item.name }}</span></div><div class="tb2"><div class="tbd">{{ item.factory }}</div><div class="tbd">{{ item.quality }}</div><div class="tbd tbh">{{ statsMode==='6m'?item.sales6m:item.salesAll }}%</div></div><div style="display:flex;align-items:center"><div class="bn"><div class="bf" :style="{width:(statsMode==='6m'?item.sales6m:item.salesAll)+'%'}"></div></div></div></div><div v-if="!stats.topListFull.length" class="mono" style="font-size:10px;opacity:.5">НЕТ ДАННЫХ</div></div></div>
          </section></div></div>

          <!-- Popups (teleported) -->
          <teleport to="body">
            <!-- Brand search popup -->
            <transition name="pop"><div v-if="showBrandMenu" class="popup-teleport" :style="[brandMenuStyle,pVars]"><div style="width:100%"><input v-model="tempBrandInput" type="search" inputmode="search" enterkeyhint="search" placeholder="ПОИСК БРЕНДА…" class="pinp main-font"/></div><div class="bsc"><button @click="clearBrands" class="bbtn ab main-font"><svg style="width:14px;height:14px;flex-shrink:0" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12S6.5 22 12 22 22 17.5 22 12 17.5 2 12 2M10 17L5 12L6.41 10.59L10 14.17L17.59 6.58L19 8L10 17Z"/></svg><span>ВСЕ</span></button><button v-for="b in filteredBrandsDropdown" :key="b" @click="toggleBrandSelection(b)" class="bbtn main-font"><span class="btx">{{ b }}</span><svg v-if="selectedBrands.includes(b)" style="width:13px;height:13px" viewBox="0 0 24 24"><path fill="currentColor" d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"/></svg></button><div v-if="!filteredBrandsDropdown.length" style="font-size:10px;color:var(--dim);padding:6px 10px" class="main-font">НЕТ СОВПАДЕНИЙ</div></div></div></transition>
            <!-- Fragrance search popup -->
            <transition name="pop"><div v-if="showFragMenu" class="popup-teleport" :style="[fragMenuStyle,pVars]"><div style="width:100%"><input v-model="tempFragInput" type="search" inputmode="search" enterkeyhint="search" placeholder="ПОИСК АРОМАТА…" class="pinp main-font"/></div><div class="bsc"><button @click="clearFrags" class="bbtn ab main-font"><svg style="width:14px;height:14px;flex-shrink:0" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12S6.5 22 12 22 22 17.5 22 12 17.5 2 12 2M10 17L5 12L6.41 10.59L10 14.17L17.59 6.58L19 8L10 17Z"/></svg><span>ВСЕ</span></button><button v-for="f in filteredFragsDropdown" :key="f" @click="toggleFragSelection(f)" class="bbtn main-font"><span class="btx">{{ f }}</span><svg v-if="selectedFrags.includes(f)" style="width:13px;height:13px" viewBox="0 0 24 24"><path fill="currentColor" d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"/></svg></button><div v-if="!filteredFragsDropdown.length" style="font-size:10px;color:var(--dim);padding:6px 10px" class="main-font">НЕТ СОВПАДЕНИЙ</div></div></div></transition>
            <!-- Filters cascade panel -->
            <transition name="cascade">
              <div v-if="showFilters" class="filter-cascade" :style="pVars">
                <div class="fc-overlay" @click="showFilters=false"></div>
                <div class="fc-panel liquid-el" :style="lgStyle">
                  <div class="fc-head"><span class="fc-title main-font">ФИЛЬТРЫ</span><button @click="showFilters=false" class="fc-close">✕</button></div>
                  <!-- Новинки -->
                  <div class="ps"><span class="pl main-font">НОВИНКИ</span>
                    <div class="tgr" @click="filterPlus=!filterPlus"><span class="tgl main-font">НОВИНКИ <span class="ch chp">+</span></span><div :class="['tg',{on:filterPlus}]"><div class="tgt"></div></div></div>
                    <div class="tgr" @click="filterStar=!filterStar"><span class="tgl main-font">ВЕРСИИ <span class="ch chs">*</span></span><div :class="['tg',{on:filterStar}]"><div class="tgt"></div></div></div>
                    <div class="tgr" @click="showOut=!showOut"><span class="tgl main-font">НЕТ <span class="ch chm">-</span></span><div :class="['tg',{on:showOut}]"><div class="tgt"></div></div></div>
                  </div>
                  <!-- Дизайн — тумблер тема -->
                  <div class="ps"><span class="pl main-font">ДИЗАЙН</span>
                    <div class="theme-toggle" @click="toggleTheme">
                      <span :class="['tt-label main-font',{active:curTheme==='graphite'}]">ТЁМНАЯ</span>
                      <div :class="['tt-track',{light:curTheme==='powder'}]">
                        <div class="tt-thumb"></div>
                      </div>
                      <span :class="['tt-label main-font',{active:curTheme==='powder'}]">СВЕТЛАЯ</span>
                    </div>
                  </div>
                  <!-- Пол -->
                  <div class="ps"><span class="pl main-font">ПОЛ</span><div class="sg"><button v-for="g in genderOptions" :key="g.val" @click="activeGender=g.val" :class="['sgb main-font',{active:activeGender===g.val}]">{{ g.label }}</button></div></div>
                  <!-- Фабрика -->
                  <div class="ps"><span class="pl main-font">ФАБРИКА</span><div class="sg"><button v-for="f in factoryOptions" :key="f.val" @click="activeFactory=f.val" :class="['sgb main-font',{active:activeFactory===f.val}]">{{ f.label }}</button></div></div>
                  <!-- Качество -->
                  <div class="ps"><span class="pl main-font">КАЧЕСТВО</span><div class="sg"><button v-for="q in qualityOptions" :key="q.val" @click="activeQuality=q.val" :class="['sgb main-font',{active:activeQuality===q.val}]">{{ q.label }}</button></div></div>
                  <!-- Цена -->
                  <div class="ps"><span class="pl main-font">ЦЕНА</span><div class="sg"><button v-for="s in sortOptions" :key="s.val" @click="sortBy=s.val" :class="['sgb main-font',{active:sortBy===s.val}]"><span v-if="s.val==='id'">ID</span><span v-else>{{ s.label }}{{ s.val==='asc'?'▲':'▼' }}</span></button></div></div>
                  <!-- Столбцы -->
                  <div class="ps"><span class="pl main-font">СТОЛБЦЫ</span><div class="sg"><button v-for="(val,key) in priceLabels" :key="key" @click="togglePrice(key)" :class="['sgb main-font',{active:showPrices[key]}]">{{ val }}</button></div></div>
                  <!-- Liquid Glass Settings -->
                  <div class="ps"><span class="pl main-font">ЭФФЕКТЫ</span>
                    <div class="lg-slider"><span class="lg-lbl mono">BLUR</span><input type="range" min="0" max="40" step="1" v-model.number="lgBlur" class="lg-range"/><span class="lg-val mono">{{ lgBlur }}</span></div>
                    <div class="lg-slider"><span class="lg-lbl mono">NOISE</span><input type="range" min="0.001" max="0.05" step="0.001" v-model.number="lgNoise" class="lg-range"/><span class="lg-val mono">{{ lgNoise.toFixed(3) }}</span></div>
                    <div class="lg-slider"><span class="lg-lbl mono">DISTORT</span><input type="range" min="0" max="120" step="1" v-model.number="lgDistort" class="lg-range"/><span class="lg-val mono">{{ lgDistort }}</span></div>
                    <div class="lg-slider"><span class="lg-lbl mono">TINT</span><input type="range" min="0" max="100" step="1" v-model.number="lgTint" class="lg-range"/><span class="lg-val mono">{{ lgTint }}%</span></div>
                  </div>
                </div>
              </div>
            </transition>
          </teleport>

          <!-- Products -->
          <div class="gt" :class="'sz-'+cardSize">
            <div v-for="(p,index) in sortedProducts" :key="p.id+'-'+index" :class="['row','cr',{out:p.isOut}]" @click="p.link&&p.link.length>5?openLink(p.link):null">
              <div class="rc">
                <div class="cn cid"><span class="id-num mono">{{ p.id }}<span v-if="p.isOut" class="id-st" style="color:#fd4659">-</span><span v-else-if="p.hasPlus" class="id-st" style="color:#00a86b">+</span><span v-else-if="p.hasStar" class="id-st" style="color:#a020f0">*</span></span></div>
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

    <!-- Fixed bottom ФИЛЬТРЫ button — Liquid Glass -->
    <button v-if="!loading&&!errorMsg" @click="showFilters=!showFilters" :class="['fab-filter liquid-el',{active:showFilters}]" :style="lgStyle">
      <span class="fab-ico">
        <svg width="18" height="18" viewBox="0 0 24 24"><path fill="currentColor" d="M3 17v2h6v-2H3zM3 5v2h10V5H3zm10 16v-2h8v-2h-8v-2h-2v6h2zM7 9v2H3v2h4v2h2V9H7zm14 4v-2H11v2h10zm-6-4h2V7h4V5h-4V3h-2v6z"/></svg>
      </span>
      <span class="fab-txt main-font">ФИЛЬТРЫ</span>
    </button>

    <!-- Scroll Track -->
    <div v-if="!loading&&!errorMsg" class="strack" ref="scrollTrack" @mousedown.prevent="startDrag" @touchstart.prevent="startDrag" @click="trackClick"><div class="sthumb" :style="{top:thumbTop+'%',height:thumbHeight+'%'}"></div></div>
  </div>
</template>

<script setup>
import{ref,computed,onMounted,onUnmounted,nextTick,watch}from'vue'

// ── Liquid Glass Settings ──
const lgBlur=ref(Number(localStorage.getItem('lg-blur'))||16)
const lgNoise=ref(Number(localStorage.getItem('lg-noise'))||0.012)
const lgDistort=ref(Number(localStorage.getItem('lg-distort'))||40)
const lgTint=ref(Number(localStorage.getItem('lg-tint'))||30)
const lgStyle=computed(()=>({'--lg-blur':lgBlur.value+'px','--lg-tint-opacity':lgTint.value/100}))
watch([lgBlur,lgNoise,lgDistort,lgTint],()=>{localStorage.setItem('lg-blur',lgBlur.value);localStorage.setItem('lg-noise',lgNoise.value);localStorage.setItem('lg-distort',lgDistort.value);localStorage.setItem('lg-tint',lgTint.value)})

// ── Themes (2 only: graphite + powder) ──
const saved=localStorage.getItem('bahur-theme')
const curTheme=ref(saved==='powder'?'powder':'graphite')

const T={
// Тёмная — графитовая (все синие → серые)
graphite:{bg:'#151517',text:'#d8d8de',cBg:'#1c1c20',pP:'#222226',pM:'#1e1e24',pN:'#1a1a20',pS:'#18181e',brd:'rgba(255,255,255,0.06)',dim:'#58585e',hBg:'#242428',sBg:'rgba(20,20,24,0.85)',seBg:'#0e0e12',seA:'#d8d8de',seT:'#58585e',seTA:'#0e0e10',bBg:'rgba(255,255,255,0.04)',bBrd:'rgba(255,255,255,0.07)',lBg:'rgba(0,0,0,0.4)',lBrd:'rgba(255,255,255,0.08)',aura:'#fff',panBg:'#18181c',gBase:'rgba(0,0,0,0.3)',gBrd:'rgba(255,255,255,0.08)',gShine:'rgba(255,255,255,0.06)',acc:'#a0a0a8',tRgb:'30,30,36',fabBg:'rgba(20,20,26,0.75)',fabBrd:'rgba(255,255,255,0.1)'},
// Светлая пудровая
powder:{bg:'#f5f0ed',text:'#2a2226',cBg:'#faf6f4',pP:'#efe8e4',pM:'#f0eae6',pN:'#f8f2ef',pS:'#f2ece8',brd:'rgba(160,120,100,0.1)',dim:'#b09888',hBg:'#f0e8e4',sBg:'rgba(248,244,240,0.88)',seBg:'#e8ddd6',seA:'#2a2226',seT:'#a89088',seTA:'#faf6f4',bBg:'rgba(160,120,100,0.04)',bBrd:'rgba(160,120,100,0.08)',lBg:'rgba(255,255,255,0.5)',lBrd:'rgba(160,120,100,0.1)',aura:'#2a2226',panBg:'#f8f4f0',gBase:'rgba(255,255,255,0.4)',gBrd:'rgba(160,120,100,0.1)',gShine:'rgba(255,255,255,0.7)',acc:'#7a5a48',tRgb:'250,246,244',fabBg:'rgba(248,244,240,0.8)',fabBrd:'rgba(160,120,100,0.15)'}
}

const themeVars=computed(()=>{const t=T[curTheme.value]||T.graphite;return{'--bg':t.bg,'--text':t.text,'--card-bg':t.cBg,'--pill-price':t.pP,'--pill-meta':t.pM,'--pill-name':t.pN,'--pill-search':t.pS,'--border':t.brd,'--card-border':t.brd,'--dim':t.dim,'--hover-bg':t.hBg,'--sticky-bg':t.sBg,'--seg-bg':t.seBg,'--seg-active':t.seA,'--seg-txt':t.seT,'--seg-txt-active':t.seTA,'--btn-bg':t.bBg,'--btn-brd':t.bBrd,'--liquid-bg':t.lBg,'--liquid-brd':t.lBrd,'--aura-text':t.aura,'--panel-bg':t.panBg,'--glass-base':t.gBase,'--glass-brd':t.gBrd,'--glass-shine':t.gShine,'--accent':t.acc,'--p-cols':activePriceCount.value,'--text-rgb':t.tRgb,'--fab-bg':t.fabBg,'--fab-brd':t.fabBrd}})
const pVars=computed(()=>{const t=T[curTheme.value]||T.graphite;return{'--panel-bg':t.panBg,'--border':t.brd,'--text':t.text,'--dim':t.dim,'--seg-bg':t.seBg,'--seg-active':t.seA,'--seg-txt':t.seT,'--seg-txt-active':t.seTA,'--bg':t.bg,'--card-bg':t.cBg,'--text-rgb':t.tRgb,color:t.text}})
const accentColor=computed(()=>(T[curTheme.value]||T.graphite).acc)

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
const cardSize=ref('m')
const sizeOptions=[{label:'S',val:'s'},{label:'M',val:'m'},{label:'L',val:'l'}]

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
const loadData=async()=>{loading.value=true;errorMsg.value=null;try{const r=await fetch('https://docs.google.com/spreadsheets/d/e/2PACX-1vTtT4zLEY49maKt0VxanZWA2ORKO1h39Mc5wB-XcZclDTmWfroFxQNAPxomg3x0-w/pub?gid=1234145733&single=true&output=csv');if(!r.ok)throw new Error();products.value=parseCSV(await r.text());if(!products.value.length)throw new Error();setTimeout(()=>loading.value=false,1500)}catch{errorMsg.value='Не удалось подключиться к базе данных.';loading.value=false}}

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
onUnmounted(()=>{window.removeEventListener('scroll',updateThumb);window.removeEventListener('resize',updateThumb);window.removeEventListener('resize',recP)})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap');
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@300;400;700&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Kollektif&display=swap');

*{box-sizing:border-box}.main-font{font-family:'Nunito',sans-serif}.kollektif{font-family:'Kollektif','Nunito',sans-serif}.mono{font-family:'JetBrains Mono',monospace}.fw7{font-weight:700}.fw8{font-weight:800}.center{display:flex;align-items:center;justify-content:center}
.bahur-terminal{min-height:100vh;background:var(--bg);color:var(--text);font-family:'Nunito',sans-serif;touch-action:pan-y;transition:background .4s,color .4s}
::-webkit-scrollbar{width:2px;height:2px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:rgba(128,128,128,.25);border-radius:2px}
.container{max-width:1400px;margin:0 auto;padding:12px;overflow-x:hidden}

/* ══ LIQUID GLASS — чёрный на тёмной, белый на светлой ══ */
.liquid-el{position:relative;isolation:isolate}
.liquid-el::before{content:'';position:absolute;inset:0;z-index:0;border-radius:inherit;box-shadow:inset 0 1px 18px -4px var(--glass-shine);background-color:var(--glass-base);pointer-events:none}
.liquid-el::after{content:'';position:absolute;inset:0;z-index:-1;border-radius:inherit;backdrop-filter:blur(var(--lg-blur,16px)) saturate(1.3);-webkit-backdrop-filter:blur(var(--lg-blur,16px)) saturate(1.3);filter:url(#liquid-glass);-webkit-filter:url(#liquid-glass);isolation:isolate;pointer-events:none}

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
.sc-right{text-align:right}.sc-right .bm{justify-content:flex-end}
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

/* ── Sticky header — card-like, full-width, liquid glass ── */
.sn{position:sticky;top:0;z-index:100;background:var(--sticky-bg);border-radius:16px;overflow:visible;padding:6px 10px 4px;transition:background .4s;box-shadow:0 4px 24px rgba(0,0,0,.2),0 1px 0 var(--glass-brd);margin-bottom:0;border:1px solid var(--glass-brd)}

/* Stats tab — small button top-left corner */
.stats-tab{position:absolute;top:-1px;left:14px;transform:translateY(-100%);background:var(--card-bg);border:1px solid var(--glass-brd);border-bottom:none;border-radius:8px 8px 0 0;padding:3px 10px;font-size:9px;cursor:pointer;color:var(--dim);transition:all .2s;z-index:101;line-height:1}
.stats-tab:hover{color:var(--text)}.stats-tab.active{color:var(--text);background:var(--sticky-bg)}

/* ── Table header — clickable БРЕНД/АРОМАТ ── */
.th{display:grid;grid-template-columns:22px .7fr 1fr repeat(3,52px) calc(var(--p-cols)*52px);align-items:stretch;padding:0}
.hn{padding:2px;display:flex;align-items:stretch}
.hid{padding:2px;display:flex;align-items:center;justify-content:center}
.hid .hp{width:22px;font-size:7px;justify-content:center;padding:0}
.hpl{padding:2px;display:flex;align-items:stretch;justify-content:center}.hpr{display:grid;padding:2px;gap:3px}.hpr .hpl{padding:0}
.hp{display:flex;align-items:center;justify-content:center;width:100%;height:30px;border-radius:8px;font-size:8px;font-weight:800;letter-spacing:.8px;color:var(--dim);white-space:nowrap;transition:background .3s}
.mhp{background:var(--pill-meta)}.php{background:var(--pill-price)}

/* Clickable header buttons (brand/aroma) */
.hdr-click{border:none;cursor:pointer;gap:6px;transition:all .2s;background:var(--card-bg);color:var(--dim);justify-content:flex-start;padding-left:10px;font-size:9px;letter-spacing:1.2px}
.hdr-click:hover{background:var(--hover-bg)}
.hdr-click.active{background:var(--text);color:var(--bg)}
.hdr-click.active .search-ico{color:var(--bg)}
.search-ico{width:12px;height:12px;flex-shrink:0;opacity:.5}
.nhp{background:var(--card-bg);justify-content:flex-start;padding-left:10px;font-size:9px;letter-spacing:1.2px}

/* Size S/M/L — between header and table */
.size-seg{display:flex;justify-content:center;gap:0;padding:6px 0 4px}
.size-btn{background:var(--card-bg);border:1px solid var(--border);color:var(--dim);padding:3px 16px;font-size:9px;font-weight:800;letter-spacing:.5px;cursor:pointer;transition:all .15s}
.size-btn:first-child{border-radius:6px 0 0 6px}
.size-btn:last-child{border-radius:0 6px 6px 0}
.size-btn:not(:first-child){margin-left:-1px}
.size-btn.active{background:var(--text);color:var(--bg);border-color:var(--text);z-index:1;position:relative}

/* ── FAB Filter button — matches theme ── */
.fab-filter{position:fixed;bottom:20px;left:50%;transform:translateX(calc(-50% + 30px));z-index:150;display:flex;align-items:center;gap:8px;padding:10px 20px;border-radius:24px;border:1px solid var(--fab-brd);cursor:pointer;color:var(--text);background:var(--fab-bg);box-shadow:0 4px 20px rgba(0,0,0,.2);transition:all .25s}
.fab-filter.active{box-shadow:0 2px 12px rgba(0,0,0,.3);transform:translateX(calc(-50% + 30px)) scale(.96)}
.fab-filter:hover{transform:translateX(calc(-50% + 30px)) translateY(-2px);box-shadow:0 8px 28px rgba(0,0,0,.3)}
.fab-ico{display:flex;align-items:center}.fab-txt{font-size:10px;font-weight:800;letter-spacing:1.2px}

/* ── Filter cascade panel ── */
.filter-cascade{position:fixed;inset:0;z-index:9000;display:flex;align-items:flex-end;justify-content:center}
.fc-overlay{position:absolute;inset:0;background:rgba(0,0,0,.4);backdrop-filter:blur(2px)}
.fc-panel{position:relative;z-index:1;width:100%;max-width:400px;max-height:85vh;overflow-y:auto;border-radius:24px 24px 0 0;padding:16px;display:flex;flex-direction:column;gap:6px;background:var(--panel-bg);border:1px solid var(--border);border-bottom:none;box-shadow:0 -12px 48px rgba(0,0,0,.3);scrollbar-width:thin;scrollbar-color:rgba(128,128,128,.3) transparent}
.fc-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:4px}
.fc-title{font-size:11px;font-weight:800;letter-spacing:1.5px}
.fc-close{background:transparent;border:none;color:var(--dim);font-size:18px;cursor:pointer;padding:4px 8px}
.cascade-enter-active{transition:all .3s ease}.cascade-leave-active{transition:all .2s ease}
.cascade-enter-from .fc-panel{transform:translateY(100%)}.cascade-leave-to .fc-panel{transform:translateY(100%)}
.cascade-enter-from .fc-overlay{opacity:0}.cascade-leave-to .fc-overlay{opacity:0}

/* Theme toggle — tumbler */
.theme-toggle{display:flex;align-items:center;gap:10px;justify-content:center;padding:8px 0;cursor:pointer;user-select:none}
.tt-label{font-size:9px;font-weight:800;letter-spacing:.8px;color:var(--dim);transition:color .2s}
.tt-label.active{color:var(--text)}
.tt-track{width:42px;height:22px;border-radius:22px;background:var(--seg-bg);border:1px solid var(--border);position:relative;transition:all .3s;flex-shrink:0}
.tt-thumb{width:16px;height:16px;border-radius:50%;background:var(--text);position:absolute;left:2px;top:2px;transition:transform .3s}
.tt-track.light .tt-thumb{transform:translateX(20px)}

/* LG Sliders */
.lg-slider{display:flex;align-items:center;gap:6px;padding:4px 0}
.lg-lbl{font-size:7px;font-weight:700;color:var(--dim);width:44px;flex-shrink:0;letter-spacing:.5px}
.lg-range{flex:1;height:3px;-webkit-appearance:none;appearance:none;background:var(--border);border-radius:2px;outline:none}
.lg-range::-webkit-slider-thumb{-webkit-appearance:none;width:12px;height:12px;border-radius:50%;background:var(--text);cursor:pointer;box-shadow:0 1px 4px rgba(0,0,0,.3)}
.lg-val{font-size:7px;font-weight:700;color:var(--dim);width:32px;text-align:right;flex-shrink:0}

/* Popups */
.co{position:fixed;top:0;left:0;width:100vw;height:100vh;z-index:98;background:transparent}
.popup-teleport{background:var(--panel-bg);border:1px solid var(--border);border-radius:14px;padding:12px;box-shadow:0 20px 60px rgba(0,0,0,.5);display:flex;flex-direction:column;gap:8px;max-height:calc(100vh - 120px);overflow-y:auto;font-family:'Nunito',sans-serif;transition:background .3s,border-color .3s,color .3s}
.pop-enter-active,.pop-leave-active{transition:all .18s cubic-bezier(.16,1,.3,1)}.pop-enter-from,.pop-leave-to{opacity:0;transform:translateY(-6px) scale(.97)}
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
.sgb.active{background:var(--seg-active);color:var(--seg-txt-active);box-shadow:0 1px 4px rgba(0,0,0,.3)}

/* ── Product grid ── */
.gt{display:flex;flex-direction:column;gap:4px;width:100%;min-width:700px;padding-top:4px;padding-bottom:80px}
.row{display:grid;grid-template-columns:22px .7fr 1fr repeat(3,52px) calc(var(--p-cols)*52px);align-items:stretch;width:100%;background:var(--card-bg);border:1px solid var(--card-border);border-radius:14px;position:relative;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,.08);transition:transform .18s,box-shadow .18s,background .3s;padding:3px}
.row::before{content:'';position:absolute;inset:0;border-radius:inherit;background:repeating-conic-gradient(rgba(128,128,128,.012) 0% 25%,transparent 0% 50%) 0 0/4px 4px;pointer-events:none;z-index:1;opacity:.8}
.row.cr:hover{transform:translateY(-1px);box-shadow:0 5px 18px rgba(0,0,0,.15);background:var(--hover-bg)}
.rc{display:contents}.cr{cursor:pointer}.out{opacity:.4;filter:grayscale(50%)}

/* ID column */
.cid{display:flex;align-items:center;justify-content:center;padding:2px 0}
.id-num{font-size:8px;font-weight:700;color:var(--dim);opacity:.7;display:flex;align-items:center;gap:1px;line-height:1}
.id-st{font-size:9px;font-weight:900}

/* Brand column */
.cn{display:flex;align-items:stretch;padding:2px}
.cbrand .pn{background:var(--pill-meta);border-radius:10px;padding:6px 8px;width:100%;display:flex;align-items:center;justify-content:center;min-height:34px;transition:background .3s}
.pn-brand .bc{font-size:11px;font-weight:700;display:block;text-transform:uppercase;letter-spacing:1px;text-align:center}

/* Aroma column */
.caroma .pn{background:var(--pill-name);border-radius:10px;padding:6px 10px;width:100%;display:flex;flex-direction:column;justify-content:center;min-height:34px;transition:background .3s;position:relative}
.st2{font-weight:700;font-size:11px;line-height:1.2;text-transform:uppercase;letter-spacing:1px}

/* Meta pills (mobile) */
.mm{display:none;margin-top:4px;gap:3px;align-items:center;flex-wrap:wrap}
.mb{background:var(--pill-meta);border-radius:5px;padding:2px 5px;font-size:7px;font-weight:800;text-transform:uppercase;transition:background .3s}

/* Desktop meta columns */
.cm{display:flex;align-items:stretch;padding:2px}.do{}
.pm{background:var(--pill-meta);border-radius:8px;padding:0 3px;font-size:8px;font-weight:800;width:100%;height:100%;min-height:34px;display:flex;align-items:center;justify-content:center;transition:background .3s}

/* ── Prices — красивые квадратики ── */
.cp{display:grid;gap:3px;padding:2px;align-items:stretch}
.pp{background:var(--pill-price);border:1px solid var(--border);border-radius:10px;padding:0 4px;font-size:10px;font-weight:700;width:100%;min-height:34px;display:flex;align-items:center;justify-content:center;transition:all .3s;color:var(--accent);gap:1px}
.pp-main{font-weight:800;font-size:11px}
.pp-cur{font-size:8px;opacity:.6;margin-left:1px}

/* Scroll track */
.strack{position:fixed;right:3px;top:15px;bottom:15px;width:14px;z-index:200;display:flex;justify-content:center;touch-action:none}
.sthumb{position:absolute;width:3px;background:var(--text);border-radius:2px;opacity:.2;transition:opacity .2s}
.strack:hover .sthumb{opacity:.5}
.strack::before{content:'';position:absolute;top:0;bottom:0;width:1px;background:var(--border)}
.tf{}

/* Card sizes */
.sz-s .row{padding:2px}.sz-s .pn{min-height:28px;padding:4px 6px}.sz-s .st2{font-size:9px}.sz-s .pn-brand .bc{font-size:9px}.sz-s .pp{min-height:28px;font-size:9px}.sz-s .pm{min-height:28px}.sz-s .hp{height:26px}
.sz-l .row{padding:4px}.sz-l .pn{min-height:44px;padding:8px 12px}.sz-l .st2{font-size:14px}.sz-l .pn-brand .bc{font-size:13px}.sz-l .pp{min-height:44px;font-size:12px}.sz-l .pm{min-height:44px}.sz-l .hp{height:38px}

@media(min-width:901px){.dg{grid-template-columns:repeat(5,1fr)}.sw2{grid-column:span 5}}
@media(max-width:900px){
  .strack{display:none!important}
  .dg{grid-template-columns:1fr 1fr}.sw2{grid-column:span 2}
  .sn{margin-left:-12px;margin-right:-12px;padding-left:12px;padding-right:12px;border-radius:0 0 14px 14px}
  .stats-tab{left:24px}
  .gt{min-width:100%}
  .do{display:none!important}
  .mm{display:flex!important}
  .th,.row{grid-template-columns:20px .35fr .65fr calc(var(--p-cols)*36px)}
  .row{padding:2px;border-radius:10px}
  .cn{padding:1px}
  .cbrand .pn{padding:3px 4px;border-radius:7px;min-height:0}
  .pn-brand .bc{font-size:8px;letter-spacing:.5px}
  .caroma .pn{padding:4px 6px;border-radius:7px;min-height:0}
  .st2{font-size:9px}
  .id-num{font-size:7px}
  .mm{margin-top:2px;gap:2px}.mb{padding:1px 4px;font-size:6px;border-radius:4px}
  .cp{padding:1px;gap:2px}.pp{font-size:9px;min-height:0;border-radius:6px}
  .hn{padding:1px}.nhp{padding-left:6px;font-size:7px;border-radius:7px;height:28px}
  .hdr-click{font-size:7px;padding-left:6px;height:28px;border-radius:7px}
  .hpr{padding:1px;gap:2px}.hp{height:28px}
  .fab-filter{bottom:14px;padding:8px 16px;border-radius:20px}
  .fc-panel{max-width:100%;border-radius:20px 20px 0 0}
  .sz-s .st2{font-size:8px}
  .sz-l .st2{font-size:12px}
  .sz-l .pn-brand .bc{font-size:10px}
  .sz-l .row{padding:3px}
  .sz-l .caroma .pn{padding:6px 8px}
}
</style>
