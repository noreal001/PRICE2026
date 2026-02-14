<template>
  <div :class="['bahur-terminal', { 'noir': isDark }]" :style="{ '--p-cols': activePriceCount }">
    <div class="container">

      <header class="header-manifest">
        <div class="header-inner">
          <button @click="showDash = !showDash" class="header-pill-btn">
            <span class="main-font">Статистика</span>
          </button>
          <button @click="isDark = !isDark" class="header-pill-btn">
            <span class="main-font">{{ isDark ? 'Свет' : 'Тьма' }}</span>
          </button>
        </div>
      </header>

      <div v-if="loading" class="loading-overlay">
        <div class="diagonal-bg"></div>
        <div class="intro-content"><span class="intro-text main-font">BAHUR</span></div>
      </div>

      <div v-if="errorMsg" class="error-zone">
        <div class="error-box-noir">
          <div class="err-icon">✕</div>
          <h3 class="err-title mono">ОШИБКА ПОДКЛЮЧЕНИЯ</h3>
          <p class="err-desc">{{ errorMsg }}</p>
          <div class="err-action">
            <button @click="loadData" class="retry-btn-noir"><span class="btn-text">ПОВТОРИТЬ</span></button>
          </div>
        </div>
      </div>

      <div v-else-if="!loading">

        <div :class="['dash-collapsible-wrapper', { 'open': showDash }]">
          <div class="dash-inner-content">
            <section class="dashboard">
              <div class="dash-grid">
                <div class="stat-card span-full">
                  <div class="split-top-row">
                    <div class="st-item">
                      <label class="d-label">АРОМАТЫ</label>
                      <div class="v mono">{{ stats.total }}</div>
                      <div class="stock-stack-info">
                        <div class="ss-row">Есть: <span class="mono">{{ stats.countAvail }}</span></div>
                        <div class="ss-row">Нет: <span class="mono">{{ stats.countOut }}</span></div>
                      </div>
                    </div>
                    <div class="st-sep"></div>
                    <div class="st-price-box">
                      <label class="d-label">СРЕДНЯЯ ЦЕНА</label>
                      <div class="avg-price-flex">
                        <div v-if="showPrices.p50" class="ap-item">50г:<span class="val">{{ stats.avg50 }}₽</span></div>
                        <div v-if="showPrices.p500" class="ap-item">500г:<span class="val">{{ stats.avg500 }}₽</span></div>
                        <div v-if="showPrices.p1000" class="ap-item">1кг:<span class="val">{{ stats.avg1000 }}₽</span></div>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="stat-card span-full">
                  <div class="stock-layout">
                    <div class="stock-left">
                      <label class="d-label">СКЛАД</label>
                      <div class="stock-big-num mono">{{ stats.availability }}%</div>
                    </div>
                    <div class="stock-right">
                      <div class="q-track-neon-thick">
                        <div class="q-fill-neon-thick" :style="{ width: stats.availability + '%' }"></div>
                      </div>
                      <div class="stock-missing-text">Отсутствует: {{ 100 - stats.availability }}%</div>
                    </div>
                  </div>
                </div>

                <div class="stat-card">
                  <label class="d-label">ФАБРИКИ</label>
                  <div class="q-list">
                    <div v-for="f in ['Luzi','Eps','Seluz']" :key="f" class="q-row-stacked">
                      <div class="q-meta"><span class="mono">{{ f }}</span><span class="mono op-5">{{ stats.factoryPerc[f.toUpperCase()] }}%</span></div>
                      <div class="q-track-neon"><div class="q-fill-neon" :style="{ width: stats.factoryPerc[f.toUpperCase()]+'%' }"></div></div>
                    </div>
                  </div>
                </div>

                <div class="stat-card">
                  <label class="d-label">КАЧЕСТВО</label>
                  <div class="q-list">
                    <div v-for="q in ['Top','Q1','Q2']" :key="q" class="q-row-stacked">
                      <div class="q-meta"><span class="mono">{{ q }}</span><span class="mono op-5">{{ stats.qualityPerc[q.toUpperCase()] }}%</span></div>
                      <div class="q-track-neon"><div class="q-fill-neon" :style="{ width: stats.qualityPerc[q.toUpperCase()]+'%' }"></div></div>
                    </div>
                  </div>
                </div>

                <div class="stat-card span-full">
                  <div class="top-header-center">
                    <button @click="toggleStatsMode" class="top-switch-btn-subtle main-font">
                      <span class="btn-subtle-label">РЕЙТИНГ:</span> {{ statsMode==='6m' ? '6 МЕС' : 'ВСЕ ВРЕМЯ' }}
                      <span class="arrow-indicator">⇄</span>
                    </button>
                  </div>
                  <div class="top-list-scroll-container">
                    <div v-for="(item,idx) in stats.topListFull" :key="idx" class="top-row-compact">
                      <div class="tr-left-main">
                        <span class="top-num mono">{{ idx+1 }}.</span>
                        <span class="top-name kollektif" :title="item.name">{{ item.name }}</span>
                      </div>
                      <div class="tr-mid-graph">
                        <div class="mini-bar-track"><div class="mini-bar-fill" :style="{ width:(statsMode==='6m'?item.sales6m:item.salesAll)+'%' }"></div></div>
                      </div>
                      <div class="tr-right-meta">
                        <div class="badge-mini">{{ item.factory }}</div>
                        <div class="badge-mini">{{ item.quality }}</div>
                        <span class="top-val mono">{{ statsMode==='6m'?item.sales6m:item.salesAll }}%</span>
                      </div>
                    </div>
                    <div v-if="stats.topListFull.length===0" class="op-5 mono" style="font-size:10px">НЕТ ДАННЫХ</div>
                  </div>
                </div>
              </div>
            </section>
          </div>
        </div>

        <!-- overlay закрывает меню — z-index 98 (ниже sticky=100) -->
        <div v-if="anyMenuOpen" class="click-overlay" @click="closeAllMenus"></div>

        <div class="table-frame">
          <div class="sticky-nav-group" ref="stickyRef">
            <section class="controls-luxury">
              <!-- кнопки-триггеры -->
              <div class="ctrl-row">
                <!-- БРЕНДЫ -->
                <div class="ctrl-item" ref="brandBtnRef">
                  <button @click="toggleBrandMenu"
                    :class="['main-ctrl-btn',{active:showBrandMenu||selectedBrands.length>0}]">
                    <span class="main-font fw7 truncate">{{ brandLabel }}</span>
                    <svg class="arr" viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17L16.59 8.59L18 10L12 16L6 10Z"/></svg>
                  </button>
                </div>
                <!-- СТАТУС -->
                <div class="ctrl-item" ref="statusBtnRef">
                  <button @click="toggleNewMenu"
                    :class="['main-ctrl-btn',{active:showNewMenu||filterPlus||filterStar||showOut}]">
                    <span class="main-font fw7">Статус</span>
                    <svg class="arr" viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17L16.59 8.59L18 10L12 16L6 10Z"/></svg>
                  </button>
                </div>
                <!-- ФИЛЬТР -->
                <div class="ctrl-item" ref="filterBtnRef">
                  <button @click="toggleFilterMenu"
                    :class="['main-ctrl-btn',{active:showFilters}]">
                    <span class="main-font fw7">{{ showFilters ? 'Закрыть' : 'Фильтр' }}</span>
                    <svg class="arr" viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17L16.59 8.59L18 10L12 16L6 10Z"/></svg>
                  </button>
                </div>
              </div>
            </section>

            <!-- шапка таблицы -->
            <div class="tbl-head">
              <div class="h-id"></div>
              <div class="h-name">
                <div class="search-wrap">
                  <svg class="s-ico" viewBox="0 0 24 24"><path fill="currentColor" d="M9.5,3A6.5,6.5 0 0,1 16,9.5C16,11.11 15.41,12.59 14.44,13.73L14.71,14H15.5L20.5,19L19,20.5L14,15.5V14.71L13.73,14.44C12.59,15.41 11.11,16 9.5,16A6.5,6.5 0 0,1 3,9.5A6.5,6.5 0 0,1 9.5,3M9.5,5C7,5 5,7 5,9.5C5,12 7,14 9.5,14C12,14 14,12 14,9.5C14,7 12,5 9.5,5Z"/></svg>
                  <input v-model="searchQuery" type="text" placeholder="АРОМАТЫ / ПОИСК…" class="s-inp kollektif"/>
                  <button v-if="searchQuery" @click="searchQuery=''" class="s-clr">✕</button>
                </div>
              </div>
              <div class="h-pill desk-only"><span class="hp meta-hp kollektif">Пол</span></div>
              <div class="h-pill desk-only"><span class="hp meta-hp kollektif">Фабрика</span></div>
              <div class="h-pill desk-only"><span class="hp meta-hp kollektif">Качество</span></div>
              <div class="h-prices" :style="priceSubGridStyle">
                <div v-if="showPrices.p50"   class="h-pill"><span class="hp price-hp mono">50г</span></div>
                <div v-if="showPrices.p500"  class="h-pill"><span class="hp price-hp mono">500г</span></div>
                <div v-if="showPrices.p1000" class="h-pill"><span class="hp price-hp mono">1кг</span></div>
              </div>
            </div>
          </div>

          <!-- POPUP МЕНЮ — teleport в body чтобы z-index не зависел от родителя -->
          <teleport to="body">
            <!-- БРЕНДЫ -->
            <transition name="pop">
              <div v-if="showBrandMenu" class="popup-teleport" :style="brandMenuStyle">
                <div class="search-input-box">
                  <input v-model="tempBrandInput" type="text" inputmode="search" placeholder="Поиск бренда…" class="popup-input main-font"/>
                </div>
                <div class="brands-scroll-area">
                  <div class="brands-list">
                    <button @click="clearBrands" class="brand-btn all-brand main-font">
                      <div class="brand-left">
                        <svg style="width:14px;height:14px;flex-shrink:0" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12S6.5 22 12 22 22 17.5 22 12 17.5 2 12 2M10 17L5 12L6.41 10.59L10 14.17L17.59 6.58L19 8L10 17Z"/></svg>
                        <span>Все</span>
                      </div>
                    </button>
                    <button v-for="b in filteredBrandsDropdown" :key="b" @click="toggleBrandSelection(b)" class="brand-btn main-font">
                      <div class="brand-left"><span class="brand-txt">{{ b }}</span></div>
                      <svg v-if="selectedBrands.includes(b)" style="width:13px;height:13px;flex-shrink:0" viewBox="0 0 24 24"><path fill="currentColor" d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"/></svg>
                    </button>
                    <div v-if="filteredBrandsDropdown.length===0" class="no-results main-font">Нет совпадений</div>
                  </div>
                </div>
              </div>
            </transition>

            <!-- СТАТУС -->
            <transition name="pop">
              <div v-if="showNewMenu" class="popup-teleport" :style="statusMenuStyle">
                <div class="toggle-row" @click="filterPlus=!filterPlus">
                  <span class="toggle-label main-font">Новинки <span class="status-chip chip-plus">+</span></span>
                  <div :class="['bw-toggle',{on:filterPlus}]"><div class="bw-thumb"></div></div>
                </div>
                <div class="toggle-row" @click="filterStar=!filterStar">
                  <span class="toggle-label main-font">Версии <span class="status-chip chip-star">*</span></span>
                  <div :class="['bw-toggle',{on:filterStar}]"><div class="bw-thumb"></div></div>
                </div>
                <div class="toggle-row" @click="showOut=!showOut">
                  <span class="toggle-label main-font">Нет <span class="status-chip chip-minus">-</span></span>
                  <div :class="['bw-toggle',{on:showOut}]"><div class="bw-thumb"></div></div>
                </div>
              </div>
            </transition>

            <!-- ФИЛЬТР -->
            <transition name="pop">
              <div v-if="showFilters" class="popup-teleport" :style="filterMenuStyle">
                <div class="popup-section">
                  <span class="popup-label main-font">Пол</span>
                  <div class="seg-ctrl">
                    <button v-for="g in genderOptions" :key="g.val" @click="activeGender=g.val" :class="['seg-btn main-font',{active:activeGender===g.val}]">{{ g.label }}</button>
                  </div>
                </div>
                <div class="popup-section">
                  <span class="popup-label main-font">Фабрика</span>
                  <div class="seg-ctrl">
                    <button v-for="f in factoryOptions" :key="f.val" @click="activeFactory=f.val" :class="['seg-btn main-font',{active:activeFactory===f.val}]">{{ f.label }}</button>
                  </div>
                </div>
                <div class="popup-section">
                  <span class="popup-label main-font">Качество</span>
                  <div class="seg-ctrl">
                    <button v-for="q in qualityOptions" :key="q.val" @click="activeQuality=q.val" :class="['seg-btn main-font',{active:activeQuality===q.val}]">{{ q.label }}</button>
                  </div>
                </div>
                <div class="popup-section">
                  <span class="popup-label main-font">Цена</span>
                  <div class="seg-ctrl">
                    <button v-for="s in sortOptions" :key="s.val" @click="sortBy=s.val" :class="['seg-btn main-font',{active:sortBy===s.val}]">
                      <span v-if="s.val==='id'">ID</span>
                      <span v-else>{{ s.label }}{{ s.val==='asc'?'▲':'▼' }}</span>
                    </button>
                  </div>
                </div>
                <div class="popup-section">
                  <span class="popup-label main-font">Столбцы</span>
                  <div class="seg-ctrl">
                    <button v-for="(val,key) in priceLabels" :key="key" @click="togglePrice(key)" :class="['seg-btn main-font',{active:showPrices[key]}]">{{ val }}</button>
                  </div>
                </div>
              </div>
            </transition>
          </teleport>

          <!-- СТРОКИ ТАБЛИЦЫ -->
          <div class="grid-table">
            <div v-for="(p,index) in sortedProducts" :key="p.id+'-'+index"
              :class="['tbl-row','clickable-row',{out:p.isOut,'sim-hover':autoHighlightId===p.id}]"
              @click="p.link&&p.link.length>5?open(p.link):null">
              <div class="row-contents">

                <div class="c-id center">
                  <div class="id-num mono">{{ p.id }}</div>
                  <div class="id-sym mono">
                    <span v-if="p.isOut" class="watermelon-txt">-</span>
                    <span v-else-if="p.hasPlus" class="jade-txt">+</span>
                    <span v-else-if="p.hasStar" class="purple-txt">*</span>
                  </div>
                </div>

                <div class="c-name">
                  <div class="pill-name">
                    <span class="brand-code kollektif">{{ p.brand }}</span>
                    <span class="scent-title kollektif">{{ p.name }}</span>
                    <div class="mob-meta">
                      <span class="mob-badge kollektif">{{ getSex(p.gender) }}</span>
                      <span class="mob-badge kollektif">{{ p.factory }}</span>
                      <span class="mob-badge kollektif">{{ p.quality }}</span>
                    </div>
                  </div>
                </div>

                <div class="c-meta desk-only center"><div class="pill-meta kollektif">{{ getSex(p.gender) }}</div></div>
                <div class="c-meta desk-only center"><div class="pill-meta kollektif">{{ p.factory }}</div></div>
                <div class="c-meta desk-only center"><div class="pill-meta kollektif">{{ p.quality }}</div></div>

                <div class="c-prices" :style="priceSubGridStyle">
                  <div v-if="showPrices.p50"   class="pill-price mono">{{ p.p50 }}₽</div>
                  <div v-if="showPrices.p500"  class="pill-price mono">{{ p.p500 }}₽</div>
                  <div v-if="showPrices.p1000" class="pill-price mono fw8">{{ p.p1000 }}₽</div>
                </div>
              </div>

              <div class="aura-overlay">
                <span class="aura-txt kollektif">ПЕРЕЙТИ К АРОМАТУ</span>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>

    <!-- кастомный скроллбар — скрыт на мобиле через CSS -->
    <div v-if="!loading&&!errorMsg" class="scroll-track" ref="scrollTrack"
      @mousedown.prevent="startDrag" @touchstart.prevent="startDrag" @click="trackClick">
      <div class="scroll-thumb" :style="{ top:thumbTop+'%', height:thumbHeight+'%' }"></div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'

const isDark = ref(true)
watch(isDark, (v) => { document.body.dataset.theme = v ? 'dark' : 'light' }, { immediate: true })
const loading = ref(true)
const errorMsg = ref(null)
const products = ref([])
const showDash = ref(false)
const statsMode = ref('6m')
const toggleStatsMode = () => { statsMode.value = statsMode.value === '6m' ? 'all' : '6m' }
const selectedBrands = ref([])
const tempBrandInput = ref('')
const showBrandMenu = ref(false)
const searchQuery = ref('')
const showFilters = ref(false)
const showNewMenu = ref(false)
const filterPlus = ref(false)
const filterStar = ref(false)
const showOut = ref(false)
const activeGender = ref('ВСЕ')
const activeQuality = ref('ВСЕ')
const sortBy = ref('id')
const activeFactory = ref('ВСЕ')
const autoHighlightId = ref(null)
let highlightInterval = null

const showPrices = ref({ p50: true, p500: true, p1000: true })
const priceLabels = { p50: '50г', p500: '500г', p1000: '1кг' }
const activePriceCount = computed(() => Object.values(showPrices.value).filter(Boolean).length)
const anyMenuOpen = computed(() => showBrandMenu.value || showNewMenu.value || showFilters.value)

const genderOptions = [{ label: 'Все', val: 'ВСЕ' }, { label: 'Муж', val: 'm' }, { label: 'Жен', val: 'w' }, { label: 'Уни', val: 'y' }]
const factoryOptions = [{ label: 'Все', val: 'ВСЕ' }, { label: 'Luzi', val: 'LUZI' }, { label: 'Eps', val: 'EPS' }, { label: 'Seluz', val: 'SELUZ' }]
const qualityOptions = [{ label: 'Все', val: 'ВСЕ' }, { label: 'Top', val: 'TOP' }, { label: 'Q1', val: 'Q1' }, { label: 'Q2', val: 'Q2' }]
const sortOptions = [{ label: 'ID', val: 'id' }, { label: 'Цена', val: 'asc' }, { label: 'Цена', val: 'desc' }]

const togglePrice = (key) => {
  if (showPrices.value[key] && Object.values(showPrices.value).filter(Boolean).length === 1) return
  showPrices.value[key] = !showPrices.value[key]
}

// ── Позиционирование popup через getBoundingClientRect ──────────────────────
const brandBtnRef = ref(null)
const statusBtnRef = ref(null)
const filterBtnRef = ref(null)

const brandMenuStyle = ref({})
const statusMenuStyle = ref({})
const filterMenuStyle = ref({})

function calcPopupStyle(btnRef) {
  const el = btnRef?.value
  if (!el) return {}
  const r = el.getBoundingClientRect()
  const isMobile = window.innerWidth <= 900
  if (isMobile) {
    const w = window.innerWidth - 24
    return { position: 'fixed', top: (r.bottom + 6) + 'px', left: '12px', width: w + 'px', zIndex: 9999 }
  }
  return { position: 'fixed', top: (r.bottom + 6) + 'px', left: r.left + 'px', zIndex: 9999 }
}

const toggleBrandMenu = async () => {
  if (showBrandMenu.value) { closeAllMenus(); return }
  closeAllMenus(); tempBrandInput.value = ''
  await nextTick()
  brandMenuStyle.value = calcPopupStyle(brandBtnRef)
  showBrandMenu.value = true
}
const toggleNewMenu = async () => {
  if (showNewMenu.value) { closeAllMenus(); return }
  closeAllMenus()
  await nextTick()
  statusMenuStyle.value = calcPopupStyle(statusBtnRef)
  showNewMenu.value = true
}
const toggleFilterMenu = async () => {
  if (showFilters.value) { closeAllMenus(); return }
  closeAllMenus()
  await nextTick()
  filterMenuStyle.value = calcPopupStyle(filterBtnRef)
  showFilters.value = true
}
const closeAllMenus = () => { showBrandMenu.value = false; showNewMenu.value = false; showFilters.value = false }

const toggleBrandSelection = (b) => {
  const i = selectedBrands.value.indexOf(b)
  if (i === -1) selectedBrands.value.push(b); else selectedBrands.value.splice(i, 1)
  closeAllMenus()
}
const clearBrands = () => { selectedBrands.value = []; closeAllMenus() }
const brandLabel = computed(() => {
  const n = selectedBrands.value.length
  return n === 0 ? 'Бренды' : `${n} Бренд${n > 1 ? 'а' : ''}`
})
const priceSubGridStyle = computed(() => ({ gridTemplateColumns: `repeat(${activePriceCount.value}, 1fr)` }))

// ── Скролл-виджет ────────────────────────────────────────────────────────────
const scrollTrack = ref(null)
const thumbTop = ref(0)
const thumbHeight = ref(10)
const updateThumb = () => {
  const winH = window.innerHeight, docH = document.documentElement.scrollHeight, scrollY = window.scrollY
  thumbHeight.value = Math.max((winH / docH) * 100, 5)
  const max = docH - winH
  thumbTop.value = max <= 0 ? 0 : (scrollY / max) * (100 - thumbHeight.value)
}
const handleDrag = (y) => {
  const track = scrollTrack.value; if (!track) return
  const r = track.getBoundingClientRect()
  const pct = Math.min(Math.max((y - r.top) / r.height, 0), 1)
  window.scrollTo({ top: pct * (document.documentElement.scrollHeight - window.innerHeight), behavior: 'auto' })
}
let isDragging = false
const startDrag = (e) => {
  isDragging = true
  handleDrag(e.touches ? e.touches[0].clientY : e.clientY)
  window.addEventListener('mousemove', onMM)
  window.addEventListener('touchmove', onTM, { passive: false })
  window.addEventListener('mouseup', stopDrag)
  window.addEventListener('touchend', stopDrag)
}
const onMM = (e) => { if (isDragging) handleDrag(e.clientY) }
const onTM = (e) => { if (isDragging) { e.preventDefault(); handleDrag(e.touches[0].clientY) } }
const stopDrag = () => {
  isDragging = false
  window.removeEventListener('mousemove', onMM)
  window.removeEventListener('touchmove', onTM)
  window.removeEventListener('mouseup', stopDrag)
  window.removeEventListener('touchend', stopDrag)
}
const trackClick = (e) => handleDrag(e.clientY)

// ── Данные ───────────────────────────────────────────────────────────────────
const parseCSV = (data) => {
  try {
    return data.split(/\r?\n/).filter(l => l.trim()).map(row => {
      const c = row.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/).map(x => x.replace(/^"|"$/g, '').trim())
      if (!c[0] || isNaN(parseInt(c[0])) || !c[2]) return null
      const g = c[4] ? c[4].toLowerCase().trim() : ''
      const fG = (g==='m'||g==='м'||g.includes('муж')) ? 'm' : (g==='w'||g==='ж'||g.includes('жен')) ? 'w' : (g==='y'||g==='у'||g.includes('уни')) ? 'y' : ''
      const st = c[10] ? c[10].trim() : ''
      return { id:c[0], link:c[1]||'', brand:c[2]||'', name:c[3]||'', gender:fG,
        factory:c[5]||'', quality:c[6]||'', p50:parseInt(c[7])||0,
        p500:parseInt(c[8])||0, p1000:parseInt(c[9])||0,
        status:st, hasPlus:st.includes('+'), hasStar:st.includes('*'), isOut:st.includes('-'),
        sales6m:parseFloat(c[11])||0, salesAll:parseFloat(c[12])||0 }
    }).filter(Boolean)
  } catch(e) { return [] }
}

const loadData = async () => {
  loading.value = true; errorMsg.value = null
  try {
    const r = await fetch('https://docs.google.com/spreadsheets/d/e/2PACX-1vTtT4zLEY49maKt0VxanZWA2ORKO1h39Mc5wB-XcZclDTmWfroFxQNAPxomg3x0-w/pub?gid=1234145733&single=true&output=csv')
    if (!r.ok) throw new Error()
    products.value = parseCSV(await r.text())
    if (!products.value.length) throw new Error()
    startAutoHighlight()
    setTimeout(() => loading.value = false, 1500)
  } catch { errorMsg.value = 'Не удалось подключиться к базе данных.'; loading.value = false }
}

const startAutoHighlight = () => {
  if (highlightInterval) clearInterval(highlightInterval)
  highlightInterval = setInterval(() => {
    const list = sortedProducts.value
    if (list.length) {
      const p = list[Math.floor(Math.random() * list.length)]
      if (p) { autoHighlightId.value = p.id; setTimeout(() => { autoHighlightId.value = null }, 2000) }
    }
  }, 5000)
}

const uniqueBrands = computed(() => { const s = new Set(); products.value.forEach(p => p.brand && s.add(p.brand)); return Array.from(s).sort() })
const filteredBrandsDropdown = computed(() => {
  const q = tempBrandInput.value.toLowerCase()
  return q ? uniqueBrands.value.filter(b => b.toLowerCase().includes(q)) : uniqueBrands.value
})

const filteredProducts = computed(() => products.value.filter(p => {
  if (selectedBrands.value.length && !selectedBrands.value.includes(p.brand)) return false
  const q = searchQuery.value.toLowerCase()
  if (q && !p.name.toLowerCase().includes(q) && !p.brand.toLowerCase().includes(q)) return false
  if (activeGender.value !== 'ВСЕ' && p.gender !== activeGender.value) return false
  if (activeQuality.value !== 'ВСЕ' && p.quality !== activeQuality.value) return false
  if (activeFactory.value !== 'ВСЕ' && !p.factory.toUpperCase().includes(activeFactory.value)) return false
  if (filterPlus.value && !p.hasPlus) return false
  if (filterStar.value && !p.hasStar) return false
  if (!showOut.value && p.isOut) return false
  return true
}))

const sortedProducts = computed(() => {
  const list = [...filteredProducts.value]
  if (sortBy.value === 'asc') list.sort((a,b) => a.p1000 - b.p1000)
  else if (sortBy.value === 'desc') list.sort((a,b) => b.p1000 - a.p1000)
  else list.sort((a,b) => a.id - b.id)
  return list
})

const stats = computed(() => {
  const p = filteredProducts.value, n = p.length || 1
  let s50=0, s500=0, s1000=0, avail=0, out=0
  const qual = { TOP:0, Q1:0, Q2:0 }
  const fac = { LUZI:0, EPS:0, SELUZ:0 }
  p.forEach(i => {
    if (qual[i.quality] !== undefined) qual[i.quality]++
    if (!i.isOut) avail++; else out++
    s50+=i.p50; s500+=i.p500; s1000+=i.p1000
    const f = i.factory.toUpperCase()
    if (f.includes('LUZI')) fac.LUZI++; else if (f.includes('EPS')) fac.EPS++; else if (f.includes('SELUZ')) fac.SELUZ++
  })
  const topListFull = [...p].sort((a,b) => {
    return (statsMode.value==='6m' ? b.sales6m-a.sales6m : b.salesAll-a.salesAll)
  }).slice(0,50)
  return {
    total:p.length, countAvail:avail, countOut:out, availability:Math.round(avail/n*100),
    avg50:Math.round(s50/n), avg500:Math.round(s500/n), avg1000:Math.round(s1000/n),
    qualityPerc:{ TOP:Math.round(qual.TOP/n*100), Q1:Math.round(qual.Q1/n*100), Q2:Math.round(qual.Q2/n*100) },
    factoryPerc:{ LUZI:Math.round(fac.LUZI/n*100), EPS:Math.round(fac.EPS/n*100), SELUZ:Math.round(fac.SELUZ/n*100) },
    topListFull
  }
})

const getSex = (g) => ({ m:'Муж', w:'Жен', y:'Уни' }[g] || '—')
const open = (u) => window.open(u.startsWith('http') ? u : `https://${u}`, '_blank')

onMounted(() => {
  const st = document.createElement('style')
  st.id = 'bahur-global'
  st.textContent = [
    'html::-webkit-scrollbar{display:none!important}',
    'html{scrollbar-width:none!important;-ms-overflow-style:none!important}',
    /* popup teleport живёт в body — задаём переменные через data-атрибут */
    '.popup-teleport{',
    '--panel-bg:#111113;--border:rgba(255,255,255,0.07);--text:#e8e8ec;--dim:#4a4a54;',
    '--seg-bg:#08080a;--seg-active:#fff;--seg-txt:#3a3a44;--seg-txt-active:#000;',
    'font-family:Nunito,sans-serif;',
    '}',
    /* светлая тема: родитель bahur-terminal не-noir — ставим data через watch */
    'body[data-theme="light"] .popup-teleport{',
    '--panel-bg:#fafafa;--border:rgba(0,0,0,0.07);--text:#0f0f11;--dim:#aaa;',
    '--seg-bg:#d4d4e0;--seg-active:#111;--seg-txt:#bbb;--seg-txt-active:#fff;',
    '}'
  ].join('')
  document.head.appendChild(st)
  let meta = document.querySelector('meta[name=viewport]')
  if (!meta) { meta = document.createElement('meta'); meta.name='viewport'; document.head.appendChild(meta) }
  meta.content = 'width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no'
  loadData()
  window.addEventListener('scroll', updateThumb)
  window.addEventListener('resize', updateThumb)
})
onUnmounted(() => {
  if (highlightInterval) clearInterval(highlightInterval)
  window.removeEventListener('scroll', updateThumb)
  window.removeEventListener('resize', updateThumb)
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap');
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@300;400;700&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Kollektif&display=swap');

.main-font  { font-family: 'Nunito', sans-serif; }
.kollektif  { font-family: 'Kollektif', 'Nunito', sans-serif; }
.mono       { font-family: 'JetBrains Mono', monospace; }
.fw7 { font-weight: 700; }
.fw8 { font-weight: 800; }

/* ── ТЕМЫ ────────────────────────────────────────────── */
.bahur-terminal {
  --bg: #19191b;
  --text: #e8e8ec;
  --border: rgba(255,255,255,0.06);
  --dim: #4a4a54;
  --card-bg: #111113;
  --card-border: rgba(255,255,255,0.04);
  --panel-bg: #111113;
  /* плашки: тёмная < meta < name (светлее всех) */
  --pill-price: #0b0b0d;
  --pill-meta:  #16161a;
  --pill-name:  #23232a;   /* светлее meta */
  --pill-search:#0d0d10;
  --liquid-bg: rgba(255,255,255,0.06);
  --liquid-brd: rgba(255,255,255,0.12);
  --aura-text: #fff;
  --hover-bg: #16161a;
  --sticky-bg: rgba(13,13,15,0.97);
  --seg-bg: #08080a;
  --seg-active: #fff; --seg-txt: #3a3a44; --seg-txt-active: #000;
  --btn-bg: #111113; --btn-brd: rgba(255,255,255,0.07);
  transition: none;
  min-height: 100vh; background: var(--bg); color: var(--text);
  font-family: 'Nunito', sans-serif; touch-action: pan-y;
}
.noir {
  --bg:#19191b; --text:#e8e8ec; --border:rgba(255,255,255,0.06); --dim:#4a4a54;
  --card-bg:#111113; --card-border:rgba(255,255,255,0.04); --panel-bg:#111113;
  --pill-price:#0b0b0d; --pill-meta:#16161a; --pill-name:#23232a; --pill-search:#0d0d10;
  --liquid-bg:rgba(255,255,255,0.06); --liquid-brd:rgba(255,255,255,0.12);
  --aura-text:#fff; --hover-bg:#16161a; --sticky-bg:rgba(13,13,15,0.97);
  --seg-bg:#08080a; --seg-active:#fff; --seg-txt:#3a3a44; --seg-txt-active:#000;
  --btn-bg:#111113; --btn-brd:rgba(255,255,255,0.07);
}
.bahur-terminal:not(.noir) {
  --bg:#f0f0f4; --text:#0f0f11; --border:rgba(0,0,0,0.07); --dim:#aaa;
  --card-bg:#fafafa; --card-border:rgba(0,0,0,0.05); --panel-bg:#fafafa;
  --pill-price:#e0e0ea; --pill-meta:#e8e8f0; --pill-name:#f0f0f6;
  --pill-search:#e2e2ec;
  --liquid-bg:rgba(0,0,0,0.04); --liquid-brd:rgba(0,0,0,0.1);
  --aura-text:#111; --hover-bg:#f4f4f8; --sticky-bg:rgba(240,240,244,0.97);
  --seg-bg:#d4d4e0; --seg-active:#111; --seg-txt:#bbb; --seg-txt-active:#fff;
  --btn-bg:#e5e5ee; --btn-brd:rgba(0,0,0,0.07);
}

/* ── SCROLLBARS (внутренние) ─────────────────────────── */
::-webkit-scrollbar { width: 2px; height: 2px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: rgba(128,128,128,0.25); border-radius: 2px; }

.container { max-width: 1400px; margin: 0 auto; padding: 15px; }

/* ── LOADING ──────────────────────────────────────────── */
.loading-overlay { position:fixed; inset:0; background:#000; z-index:2000; display:flex; justify-content:center; align-items:center; overflow:hidden; }
.diagonal-bg { position:absolute; inset:0; background:repeating-linear-gradient(45deg,transparent,transparent 10px,rgba(255,255,255,0.3) 10px,rgba(255,255,255,0.3) 13px); background-size:200% 200%; animation:bg-move 4s linear infinite; }
@keyframes bg-move { to { background-position:100% 100%; } }
.intro-content { position:relative; z-index:10; }
.intro-text { font-weight:800; font-size:60px; color:#fff; letter-spacing:8px; opacity:0; animation:scale-in 1.5s cubic-bezier(0.2,0.8,0.2,1) forwards; }
@keyframes scale-in { 0%{transform:scale(0.8);opacity:0;filter:blur(10px)} 100%{transform:scale(1);opacity:1;filter:blur(0)} }

/* ── ERROR ────────────────────────────────────────────── */
.error-zone { display:flex; justify-content:center; align-items:center; height:50vh; }
.error-box-noir { text-align:center; border:1px solid var(--border); padding:40px 60px; border-radius:4px; background:var(--bg); }
.err-icon { font-size:30px; margin-bottom:15px; opacity:0.8; }
.err-title { font-size:14px; margin-bottom:10px; letter-spacing:1px; }
.err-desc { font-size:12px; color:var(--dim); margin-bottom:25px; }
.retry-btn-noir { background:var(--text); border:none; color:var(--bg); padding:12px 24px; font-family:'JetBrains Mono',monospace; font-size:11px; cursor:pointer; font-weight:700; text-transform:uppercase; }

/* ── КАСТОМНЫЙ СКРОЛЛБАР ─────────────────────────────── */
.scroll-track { position:fixed; right:3px; top:15px; bottom:15px; width:14px; z-index:200; display:flex; justify-content:center; touch-action:none; }
.scroll-thumb { position:absolute; width:4px; background:var(--text); border-radius:2px; opacity:0.25; transition:opacity 0.2s; }
.scroll-track:hover .scroll-thumb { opacity:0.6; }
.scroll-track::before { content:''; position:absolute; top:0; bottom:0; width:1px; background:var(--border); }

/* ── HEADER ───────────────────────────────────────────── */
.header-manifest { margin-bottom:25px; }
.header-inner { display:flex; justify-content:space-between; align-items:center; padding:10px 0; border-bottom:1px solid var(--border); }
.header-pill-btn { background:transparent; border:1px solid var(--border); color:var(--text); border-radius:20px; padding:6px 14px; font-size:11px; font-weight:700; cursor:pointer; display:flex; align-items:center; gap:5px; }
.header-pill-btn:hover { background:var(--btn-bg); }

/* ── DASHBOARD ────────────────────────────────────────── */
.dash-collapsible-wrapper { display:grid; grid-template-rows:0fr; transition:grid-template-rows 0.3s ease; }
.dash-collapsible-wrapper.open { grid-template-rows:1fr; margin-bottom:20px; }
.dash-inner-content { overflow:hidden; }
.dash-grid { display:grid; grid-template-columns:repeat(6,1fr); gap:10px; }
.stat-card { border:1px solid var(--border); padding:18px; background:var(--card-bg); border-left:3px solid var(--text); border-radius:12px; }
.span-full { grid-column:span 6; }
.d-label { display:block; font-size:9px; font-weight:800; color:var(--dim); margin-bottom:12px; letter-spacing:1.5px; text-transform:uppercase; }
.v { font-size:24px; font-weight:800; }
.q-row-stacked { margin-bottom:10px; }
.q-meta { display:flex; justify-content:space-between; font-size:10px; font-weight:700; margin-bottom:5px; }
.op-5 { opacity:0.5; }
.q-track-neon { height:2px; background:var(--border); border-radius:1px; overflow:hidden; }
.q-fill-neon { height:100%; background:var(--text); }
.split-top-row { display:flex; gap:20px; }
.st-item, .st-price-box { flex:1; }
.st-sep { width:1px; background:var(--border); margin:0 10px; opacity:0.5; }
.avg-price-flex { display:flex; flex-direction:column; gap:4px; }
.ap-item { font-family:'JetBrains Mono',monospace; font-size:12px; color:var(--dim); }
.ap-item .val { color:var(--text); font-weight:800; font-size:13px; margin-left:5px; }
.stock-stack-info { display:flex; flex-direction:column; margin-top:10px; gap:2px; }
.ss-row { font-size:11px; color:var(--dim); font-weight:700; }
.ss-row span { color:var(--text); margin-left:4px; }
.stock-layout { display:flex; align-items:center; gap:15px; }
.stock-left { flex-shrink:0; }
.stock-big-num { font-size:32px; font-weight:800; line-height:1; }
.stock-right { flex-grow:1; }
.q-track-neon-thick { height:6px; background:var(--border); border-radius:3px; overflow:hidden; margin-bottom:6px; }
.q-fill-neon-thick { height:100%; background:var(--text); }
.stock-missing-text { font-size:10px; color:var(--dim); text-align:right; }
.top-header-center { display:flex; justify-content:center; margin-bottom:10px; }
.top-switch-btn-subtle { background:transparent; border:1px solid var(--border); color:var(--text); padding:5px 12px; border-radius:20px; font-size:10px; font-weight:700; cursor:pointer; }
.btn-subtle-label { color:var(--dim); }
.top-list-scroll-container { max-height:120px; overflow-y:auto; overflow-x:hidden; display:flex; flex-direction:column; gap:3px; scrollbar-width:thin; scrollbar-color:rgba(128,128,128,0.2) transparent; }
.top-list-scroll-container::-webkit-scrollbar { width:2px; }
.top-row-compact { display:grid; grid-template-columns:minmax(0,2fr) minmax(0,1fr) auto; align-items:center; gap:6px; padding:3px 0; border-bottom:1px solid var(--border); min-width:0; }
.top-row-compact:last-child { border-bottom:none; }
.tr-left-main { display:flex; align-items:center; min-width:0; overflow:hidden; }
.top-num { color:var(--dim); margin-right:4px; font-weight:700; flex-shrink:0; font-size:10px; }
.top-name { overflow:hidden; white-space:nowrap; text-overflow:ellipsis; font-weight:700; min-width:0; font-size:11px; }
.tr-mid-graph { display:flex; align-items:center; min-width:0; }
.mini-bar-track { width:100%; height:2px; background:var(--border); border-radius:1px; overflow:hidden; }
.mini-bar-fill { height:100%; background:var(--text); }
.tr-right-meta { display:flex; align-items:center; gap:3px; flex-shrink:0; }
.badge-mini { border:1px solid var(--border); padding:1px 4px; font-size:8px; border-radius:4px; font-weight:700; }
.top-val { font-weight:800; min-width:28px; text-align:right; font-size:10px; }

/* ── STICKY NAV ───────────────────────────────────────── */
.sticky-nav-group {
  position: sticky; top: 0; z-index: 100;
  background: var(--sticky-bg);
  backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
  box-shadow: 0 4px 24px rgba(0,0,0,0.3), 0 1px 0 var(--border);
  border-radius: 0 0 20px 20px;
  overflow: visible; /* не clip popup */
}
.controls-luxury { padding: 10px 0 0; }

/* кнопки-триггеры — 3 кнопки в строку */
.ctrl-row {
  display: flex; gap: 8px; padding: 0 0 10px;
  overflow-x: auto; overflow-y: visible;
  scrollbar-width: none; -webkit-overflow-scrolling: touch;
}
.ctrl-row::-webkit-scrollbar { display: none; }
.ctrl-item { flex-shrink: 0; }
.main-ctrl-btn {
  background: var(--btn-bg); border: 1px solid var(--btn-brd);
  color: var(--text); padding: 8px 16px; border-radius: 20px;
  font-size: 11px; cursor: pointer;
  display: flex; align-items: center; gap: 6px;
  white-space: nowrap; transition: filter 0.15s;
}
.main-ctrl-btn:hover { filter: brightness(1.25); }
.main-ctrl-btn.active { background: var(--text); color: var(--bg); border-color: transparent; }
.arr { width: 10px; height: 10px; opacity: 0.5; flex-shrink: 0; }
.truncate { max-width: 140px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

/* click-overlay — z-index < sticky */
.click-overlay { position:fixed; top:0; left:0; width:100vw; height:100vh; z-index:98; background:transparent; }

/* ── POPUP (teleport в body — position:fixed) ─────────── */
.popup-teleport {
  /* стили переопределяются через :style */
  background: var(--panel-bg);
  border: 1px solid var(--border);
  border-radius: 16px; padding: 14px;
  box-shadow: 0 20px 60px rgba(0,0,0,0.75);
  display: flex; flex-direction: column; gap: 10px;
  min-width: 180px; max-width: 280px;
  /* предотвращаем выход за экран */
  max-height: calc(100vh - 120px); overflow-y: auto;
}

/* popup переменные темы (scoped не работает для teleport, используем глобальные через :root override) */
.bahur-terminal.noir ~ .popup-teleport,
body .popup-teleport {
  --panel-bg: #111113;
  --border: rgba(255,255,255,0.07);
  --text: #e8e8ec;
  --dim: #4a4a54;
  --seg-bg: #08080a;
}

.pop-enter-active, .pop-leave-active { transition: all 0.18s cubic-bezier(0.16,1,0.3,1); }
.pop-enter-from, .pop-leave-to { opacity:0; transform:translateY(-6px) scale(0.97); }

/* popup внутренности */
.search-input-box { width:100%; }
.popup-input { width:100%; background:var(--seg-bg,#0a0a0c); border:1px solid var(--border,rgba(255,255,255,0.07)); padding:9px 10px; border-radius:8px; color:var(--text,#e8e8ec); font-size:12px; outline:none; box-sizing:border-box; font-weight:600; }
.popup-input::placeholder { opacity:0.4; }
.brands-scroll-area { max-height:260px; overflow-y:auto; scrollbar-width:thin; }
.brands-list { display:flex; flex-direction:column; gap:3px; }
.brand-btn { display:flex; justify-content:space-between; align-items:center; background:transparent; color:var(--text,#e8e8ec); border:none; padding:9px 10px; border-radius:6px; cursor:pointer; font-size:12px; font-weight:600; width:100%; text-align:left; transition:background 0.12s; }
.brand-btn:hover { background:rgba(255,255,255,0.05); }
.all-brand { font-weight:800; border-bottom:1px solid var(--border,rgba(255,255,255,0.07)); border-radius:0; margin-bottom:4px; padding-bottom:10px; }
.brand-left { display:flex; align-items:center; gap:7px; overflow:hidden; }
.brand-txt { white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:180px; }
.no-results { font-size:11px; color:var(--dim,#4a4a54); padding:8px 10px; }

.toggle-row { display:flex; justify-content:space-between; align-items:center; cursor:pointer; padding:7px 0; border-bottom:1px solid var(--border,rgba(255,255,255,0.07)); gap:8px; }
.toggle-row:last-child { border-bottom:none; }
.toggle-label { font-size:11px; color:var(--text,#e8e8ec); font-weight:700; display:flex; align-items:center; gap:6px; }
.bw-toggle { width:34px; height:19px; border:1px solid var(--border,rgba(255,255,255,0.07)); border-radius:20px; position:relative; flex-shrink:0; }
.bw-thumb { width:13px; height:13px; background:var(--text,#e8e8ec); border-radius:50%; position:absolute; left:2px; top:2px; transition:transform 0.3s; }
.bw-toggle.on .bw-thumb { transform:translateX(15px); }
.status-chip { display:inline-flex; align-items:center; justify-content:center; width:18px; height:18px; border-radius:5px; font-size:12px; font-weight:900; }
.chip-plus { background:rgba(0,168,107,0.15); color:#00a86b; border:1px solid rgba(0,168,107,0.3); }
.chip-star { background:rgba(160,32,240,0.15); color:#a020f0; border:1px solid rgba(160,32,240,0.3); }
.chip-minus { background:rgba(253,70,89,0.15); color:#fd4659; border:1px solid rgba(253,70,89,0.3); }

.popup-section { margin-bottom:2px; }
.popup-label { display:block; font-size:9px; font-weight:800; color:var(--dim,#4a4a54); margin-bottom:5px; letter-spacing:1px; text-transform:uppercase; }
.seg-ctrl { display:flex; background:var(--seg-bg,#08080a); padding:3px; border-radius:8px; }
.seg-btn { flex:1; background:transparent; border:none; color:var(--seg-txt,#3a3a44); padding:6px 0; font-size:10px; font-weight:700; border-radius:5px; cursor:pointer; transition:background 0.1s,color 0.1s; }
.seg-btn.active { background:var(--seg-active,#fff); color:var(--seg-txt-active,#000); box-shadow:0 1px 4px rgba(0,0,0,0.5); }

/* ── ШАПКА ТАБЛИЦЫ ────────────────────────────────────── */
/*
  Колонки: id(40px) | name(1fr) | пол(52px) | фабрика(52px) | качество(52px) | цены(52px*n)
  Все meta+price колонки одинаковые: 52px
*/
.tbl-head {
  display: grid;
  grid-template-columns: 40px 1fr repeat(3, 52px) calc(var(--p-cols) * 52px);
  align-items: stretch;
  padding: 3px 5px 5px;
  box-sizing: border-box;
}
.h-id { display:flex; align-items:center; justify-content:center; }
.h-name { padding: 3px; display:flex; align-items:stretch; }
.h-pill { padding: 3px; display:flex; align-items:stretch; justify-content:center; }
.h-prices { display:grid; padding: 3px; gap: 4px; }
.h-prices .h-pill { padding: 0; }

/* плашка заголовка — одна высота = 40px */
.hp {
  display: flex; align-items: center; justify-content: center;
  width: 100%; height: 40px;
  border-radius: 9px;
  font-size: 8px; font-weight: 800; letter-spacing: 0.5px; text-transform: uppercase;
  color: var(--dim); box-sizing: border-box; white-space: nowrap;
}
.meta-hp { background: var(--pill-meta); }
.price-hp { background: var(--pill-price); }

/* поиск */
.search-wrap {
  display:flex; align-items:center; width:100%; height:100%;
  background:var(--pill-search); border-radius:11px; position:relative; overflow:hidden;
  min-height: 40px;
}
.s-ico { position:absolute; left:11px; width:13px; height:13px; color:var(--dim); pointer-events:none; flex-shrink:0; }
.s-inp { width:100%; height:100%; background:transparent; border:none; outline:none; color:var(--text); padding:0 28px 0 30px; font-size:10px; font-weight:800; letter-spacing:1px; text-transform:uppercase; }
.s-inp::placeholder { color:var(--dim); }
.s-clr { position:absolute; right:9px; background:transparent; border:none; color:var(--dim); cursor:pointer; font-size:11px; font-weight:bold; }

/* ── ТАБЛИЦА ──────────────────────────────────────────── */
.grid-table { display:flex; flex-direction:column; gap:5px; width:100%; min-width:700px; padding-top:6px; }
.tbl-row {
  display: grid;
  grid-template-columns: 40px 1fr repeat(3, 52px) calc(var(--p-cols) * 52px);
  align-items: stretch; box-sizing: border-box; width: 100%;
  background: var(--card-bg);
  border: 1px solid var(--card-border); border-radius: 18px;
  position: relative; overflow: hidden;
  box-shadow: 0 1px 6px rgba(0,0,0,0.12);
  transition: transform 0.18s, box-shadow 0.18s, background 0.18s;
  padding: 4px;
}
.tbl-row.clickable-row:hover, .tbl-row.sim-hover {
  transform: translateY(-1px);
  box-shadow: 0 5px 18px rgba(0,0,0,0.22);
  background: var(--hover-bg);
}
.row-contents { display: contents; }
.clickable-row { cursor: pointer; }
.out { opacity: 0.4; filter: grayscale(50%); }
.center { display:flex; align-items:center; justify-content:center; }

/* ID */
.c-id { display:flex; flex-direction:column; align-items:center; justify-content:center; gap:1px; padding:2px; }
.id-num { font-size:13px; font-weight:900; color:var(--dim); line-height:1; }
.id-sym { font-size:15px; font-weight:900; line-height:1; }

/* NAME pill — светлее meta */
.c-name { display:flex; align-items:stretch; padding:3px; }
.pill-name {
  background: var(--pill-name);
  border-radius: 11px; padding: 8px 12px;
  width: 100%; display:flex; flex-direction:column; justify-content:center;
  min-height: 40px; box-sizing:border-box;
}
.brand-code { font-size:9px; font-weight:400; opacity:0.4; display:block; text-transform:uppercase; letter-spacing:1px; }
.scent-title { font-weight:700; font-size:16px; line-height:1.2; letter-spacing:0.2px; }
.mob-meta { display:none; margin-top:5px; gap:3px; align-items:center; flex-wrap:wrap; }
.mob-badge { background:var(--pill-meta); border-radius:6px; padding:3px 5px; font-size:8px; font-weight:800; }

/* META pill — 40px высота = как заголовок */
.c-meta { display:flex; align-items:stretch; padding:3px; }
.pill-meta {
  background: var(--pill-meta);
  border-radius: 9px; padding: 0 3px;
  font-size: 9px; font-weight: 800;
  width: 100%; height: 100%; min-height: 40px;
  display: flex; align-items: center; justify-content: center;
  box-sizing: border-box; text-align: center;
}

/* PRICE — та же высота 40px, темнее всех */
.c-prices { display:grid; gap:4px; padding:3px; align-items:stretch; }
.pill-price {
  background: var(--pill-price);
  border-radius: 9px; padding: 0 2px;
  font-size: 11px; font-weight: 800;
  width: 100%; min-height: 40px;
  display: flex; align-items: center; justify-content: center;
  box-sizing: border-box;
}

/* СТАТУСЫ */
.jade-txt { color:#00a86b; }
.purple-txt { color:#a020f0; }
.watermelon-txt { color:#fd4659; }

/* HOVER AURA */
.aura-overlay {
  position:absolute; inset:0;
  display:flex; align-items:center; justify-content:center;
  opacity:0; transition:opacity 0.35s;
  z-index:10; pointer-events:none;
  backdrop-filter:blur(8px) saturate(1.3); -webkit-backdrop-filter:blur(8px) saturate(1.3);
  background:var(--liquid-bg); border-radius:inherit;
  border:1px solid transparent;
}
.tbl-row.clickable-row:hover .aura-overlay,
.tbl-row.sim-hover .aura-overlay {
  opacity:1; border-color:var(--liquid-brd);
  animation:lp 2.5s ease-in-out infinite;
}
@keyframes lp {
  0%,100% { backdrop-filter:blur(8px) saturate(1.3); }
  50%      { backdrop-filter:blur(12px) saturate(1.6); }
}
.aura-txt {
  font-size:11px; font-weight:700; letter-spacing:4px;
  color:var(--aura-text); text-transform:uppercase;
  text-shadow:0 0 16px currentColor;
  transform:translateY(10px); opacity:0; transition:0.4s;
}
.tbl-row.clickable-row:hover .aura-txt,
.tbl-row.sim-hover .aura-txt { opacity:1; transform:translateY(0); }

/* ── МОБИЛЬ ───────────────────────────────────────────── */
@media (max-width: 900px) {
  /* Скрыть кастомный ползунок */
  .scroll-track { display: none !important; }

  .dash-grid { grid-template-columns: 1fr 1fr; }
  .span-full { grid-column: span 2; }

  /* Sticky на всю ширину экрана */
  .sticky-nav-group {
    margin-left: -15px; margin-right: -15px;
    padding-left: 15px; padding-right: 15px;
    border-radius: 0 0 16px 16px;
  }

  /* Кнопки — 3 равные колонки */
  .ctrl-row {
    overflow-x: visible;
    display: grid; grid-template-columns: repeat(3, 1fr);
    gap: 6px; min-width: 0;
  }
  .ctrl-item { flex-shrink: unset; }
  .main-ctrl-btn { width: 100%; padding: 9px 6px; justify-content: center; }
  .arr { display: none; }
  .truncate { max-width: 100%; }

  /* Таблица */
  .grid-table { min-width: 100%; }
  .desk-only { display: none !important; }
  .mob-meta { display: flex !important; }

  .tbl-head {
    grid-template-columns: 32px 1fr calc(var(--p-cols) * 38px);
    padding: 2px 4px 4px;
  }
  .tbl-row {
    grid-template-columns: 32px 1fr calc(var(--p-cols) * 38px);
    padding: 3px; border-radius: 12px;
  }

  .c-id { padding: 0; }
  .id-num { font-size: 10px; }
  .id-sym { font-size: 12px; }

  /* name pill — ближе к номеру (меньше padding слева) */
  .c-name { padding: 2px 2px 2px 1px; }
  .pill-name { padding: 5px 8px 5px 6px; border-radius: 8px; min-height: 0; }
  .scent-title { font-size: 12px; }
  .brand-code { font-size: 8px; }
  .mob-meta { margin-top: 3px; gap: 3px; }
  .mob-badge { padding: 2px 5px; font-size: 8px; border-radius: 5px; }

  /* prices */
  .c-prices { padding: 2px; gap: 2px; }
  .pill-price { font-size: 10px; min-height: 0; border-radius: 7px; padding: 0 1px; }

  /* head */
  .h-name { padding: 2px; }
  .search-wrap { min-height: 34px; border-radius: 8px; }
  .s-ico { left: 8px; width: 11px; height: 11px; }
  .s-inp { padding: 0 22px 0 24px; font-size: 9px; }
  .s-clr { right: 6px; }
  .h-prices { padding: 2px; gap: 2px; }

  .aura-txt { font-size: 9px; letter-spacing: 2px; }

  .container { padding-right: 15px; }
}
</style>
