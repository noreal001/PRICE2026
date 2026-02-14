<template>
  <div class="bahur-terminal" :style="themeVars">
    <div class="container">

      <header class="header-manifest">
        <div class="header-inner">
          <button @click="showDash = !showDash" class="header-pill-btn">
            <span class="main-font">СТАТИСТИКА</span>
          </button>
          <div class="logo-bahur">BAHUR</div>
          <button @click="toggleThemeMenu" ref="themeBtnRef" class="header-pill-btn">
            <span class="main-font">ДИЗАЙН</span>
          </button>
        </div>
      </header>

      <!-- POPUP ДИЗАЙН -->
      <teleport to="body">
        <transition name="pop">
          <div v-if="showThemeMenu" class="popup-teleport design-popup" :style="[themeMenuStyle, popupThemeVars]">
            <!-- Ряд 1: Тёмные темы -->
            <div class="design-row">
              <button v-for="t in darkThemes" :key="t.id" @click="selectTheme(t.id)"
                :class="['theme-swatch',{active:currentTheme===t.id}]"
                :style="t.preview" :title="t.name">
              </button>
            </div>
            <!-- Ряд 2: Светлые темы -->
            <div class="design-row">
              <button v-for="t in lightThemes" :key="t.id" @click="selectTheme(t.id)"
                :class="['theme-swatch',{active:currentTheme===t.id}]"
                :style="t.preview" :title="t.name">
              </button>
            </div>
            <!-- Ряд 3: Шрифты -->
            <div class="design-row font-row">
              <button v-for="f in fontOptions" :key="f.id" @click="selectFont(f.id)"
                :class="['font-swatch',{active:currentFont===f.id}]"
                :style="{ fontFamily: f.family }">
                Aa
              </button>
            </div>
          </div>
        </transition>
      </teleport>

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
                <!-- Компактные карточки в ряд -->
                <div class="stat-card stat-compact">
                  <label class="d-label">АРОМАТЫ</label>
                  <div class="v mono">{{ stats.total }}</div>
                  <div class="stat-sub">
                    <span>Есть: <b class="mono">{{ stats.countAvail }}</b></span>
                    <span>Нет: <b class="mono">{{ stats.countOut }}</b></span>
                  </div>
                </div>

                <div class="stat-card stat-compact">
                  <label class="d-label">СКЛАД</label>
                  <div class="v mono">{{ stats.availability }}%</div>
                  <div class="q-track-neon-thick">
                    <div class="q-fill-neon-thick" :style="{ width: stats.availability + '%' }"></div>
                  </div>
                </div>

                <div class="stat-card stat-compact">
                  <label class="d-label">СРЕДНЯЯ ЦЕНА</label>
                  <div class="avg-price-compact">
                    <div v-if="showPrices.p50" class="ap-item">50г: <span class="val mono">{{ stats.avg50 }}₽</span></div>
                    <div v-if="showPrices.p500" class="ap-item">500г: <span class="val mono">{{ stats.avg500 }}₽</span></div>
                    <div v-if="showPrices.p1000" class="ap-item">1кг: <span class="val mono">{{ stats.avg1000 }}₽</span></div>
                  </div>
                </div>

                <div class="stat-card stat-compact">
                  <label class="d-label">ФАБРИКИ</label>
                  <div class="q-list-mini">
                    <div v-for="f in ['LUZI','EPS','SELUZ']" :key="f" class="q-row-mini">
                      <div class="q-meta-mini"><span class="mono">{{ f }}</span><span class="mono">{{ stats.factoryPerc[f] }}%</span></div>
                      <div class="q-track-neon"><div class="q-fill-neon" :style="{ width: stats.factoryPerc[f]+'%' }"></div></div>
                    </div>
                  </div>
                </div>

                <div class="stat-card stat-compact">
                  <label class="d-label">КАЧЕСТВО</label>
                  <div class="q-list-mini">
                    <div v-for="q in ['TOP','Q1','Q2']" :key="q" class="q-row-mini">
                      <div class="q-meta-mini"><span class="mono">{{ q }}</span><span class="mono">{{ stats.qualityPerc[q] }}%</span></div>
                      <div class="q-track-neon"><div class="q-fill-neon" :style="{ width: stats.qualityPerc[q]+'%' }"></div></div>
                    </div>
                  </div>
                </div>

                <div class="stat-card stat-wide">
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
                      <div class="tr-right-meta">
                        <div class="badge-mini">{{ item.factory }}</div>
                        <div class="badge-mini">{{ item.quality }}</div>
                        <div class="badge-mini percent-badge">{{ statsMode==='6m'?item.sales6m:item.salesAll }}%</div>
                      </div>
                      <div class="tr-mid-graph">
                        <div class="mini-bar-track"><div class="mini-bar-fill" :style="{ width:(statsMode==='6m'?item.sales6m:item.salesAll)+'%' }"></div></div>
                      </div>
                    </div>
                    <div v-if="stats.topListFull.length===0" class="op-5 mono" style="font-size:10px">НЕТ ДАННЫХ</div>
                  </div>
                </div>
              </div>
            </section>
          </div>
        </div>

        <!-- overlay закрывает меню -->
        <div v-if="anyMenuOpen" class="click-overlay" @click="closeAllMenus"></div>

        <div class="table-frame">
          <div class="sticky-nav-group" ref="stickyRef">
            <section class="controls-luxury">
              <!-- Поиск -->
              <div class="search-block">
                <div class="search-wrap-inline">
                  <svg class="s-ico" viewBox="0 0 24 24"><path fill="currentColor" d="M9.5,3A6.5,6.5 0 0,1 16,9.5C16,11.11 15.41,12.59 14.44,13.73L14.71,14H15.5L20.5,19L19,20.5L14,15.5V14.71L13.73,14.44C12.59,15.41 11.11,16 9.5,16A6.5,6.5 0 0,1 3,9.5A6.5,6.5 0 0,1 9.5,3M9.5,5C7,5 5,7 5,9.5C5,12 7,14 9.5,14C12,14 14,12 14,9.5C14,7 12,5 9.5,5Z"/></svg>
                  <input v-model="searchQuery" type="search" inputmode="search" enterkeyhint="search" placeholder="ПОИСК…" class="s-inp kollektif"/>
                  <button v-if="searchQuery" @click="searchQuery=''" class="s-clr">✕</button>
                </div>
              </div>
              <!-- кнопки-триггеры -->
              <div class="ctrl-row">
                <div class="ctrl-item" ref="brandBtnRef">
                  <button @click="toggleBrandMenu"
                    :class="['main-ctrl-btn',{active:showBrandMenu||selectedBrands.length>0}]">
                    <span class="main-font fw7 truncate">{{ brandLabel }}</span>
                    <svg class="arr" viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17L16.59 8.59L18 10L12 16L6 10Z"/></svg>
                  </button>
                </div>
                <div class="ctrl-item" ref="statusBtnRef">
                  <button @click="toggleNewMenu"
                    :class="['main-ctrl-btn',{active:showNewMenu||filterPlus||filterStar||showOut}]">
                    <span class="main-font fw7">НОВИНКИ</span>
                    <svg class="arr" viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17L16.59 8.59L18 10L12 16L6 10Z"/></svg>
                  </button>
                </div>
                <div class="ctrl-item" ref="filterBtnRef">
                  <button @click="toggleFilterMenu"
                    :class="['main-ctrl-btn',{active:showFilters}]">
                    <span class="main-font fw7">{{ showFilters ? 'ЗАКРЫТЬ' : 'ФИЛЬТРЫ' }}</span>
                    <svg class="arr" viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17L16.59 8.59L18 10L12 16L6 10Z"/></svg>
                  </button>
                </div>
              </div>
            </section>

            <!-- шапка таблицы -->
            <div class="tbl-head">
              <div class="h-id"></div>
              <div class="h-name"><span class="hp name-hp kollektif">АРОМАТ</span></div>
              <div class="h-pill desk-only"><span class="hp meta-hp kollektif">ПОЛ</span></div>
              <div class="h-pill desk-only"><span class="hp meta-hp kollektif">ФАБРИКА</span></div>
              <div class="h-pill desk-only"><span class="hp meta-hp kollektif">КАЧЕСТВО</span></div>
              <div class="h-prices" :style="priceSubGridStyle">
                <div v-if="showPrices.p50"   class="h-pill"><span class="hp price-hp mono">50г</span></div>
                <div v-if="showPrices.p500"  class="h-pill"><span class="hp price-hp mono">500г</span></div>
                <div v-if="showPrices.p1000" class="h-pill"><span class="hp price-hp mono">1кг</span></div>
              </div>
            </div>
          </div>

          <!-- POPUP МЕНЮ -->
          <teleport to="body">
            <!-- БРЕНДЫ -->
            <transition name="pop">
              <div v-if="showBrandMenu" class="popup-teleport" :style="[brandMenuStyle, popupThemeVars]">
                <div class="search-input-box">
                  <input v-model="tempBrandInput" type="search" inputmode="search" enterkeyhint="search" placeholder="ПОИСК БРЕНДА…" class="popup-input main-font"/>
                </div>
                <div class="brands-scroll-area">
                  <div class="brands-list">
                    <button @click="clearBrands" class="brand-btn all-brand main-font">
                      <div class="brand-left">
                        <svg style="width:14px;height:14px;flex-shrink:0" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12S6.5 22 12 22 22 17.5 22 12 17.5 2 12 2M10 17L5 12L6.41 10.59L10 14.17L17.59 6.58L19 8L10 17Z"/></svg>
                        <span>ВСЕ</span>
                      </div>
                    </button>
                    <button v-for="b in filteredBrandsDropdown" :key="b" @click="toggleBrandSelection(b)" class="brand-btn main-font">
                      <div class="brand-left"><span class="brand-txt">{{ b }}</span></div>
                      <svg v-if="selectedBrands.includes(b)" style="width:13px;height:13px;flex-shrink:0" viewBox="0 0 24 24"><path fill="currentColor" d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"/></svg>
                    </button>
                    <div v-if="filteredBrandsDropdown.length===0" class="no-results main-font">НЕТ СОВПАДЕНИЙ</div>
                  </div>
                </div>
              </div>
            </transition>

            <!-- НОВИНКИ -->
            <transition name="pop">
              <div v-if="showNewMenu" class="popup-teleport" :style="[statusMenuStyle, popupThemeVars]">
                <div class="toggle-row" @click="filterPlus=!filterPlus">
                  <span class="toggle-label main-font">НОВИНКИ <span class="status-chip chip-plus">+</span></span>
                  <div :class="['bw-toggle',{on:filterPlus}]"><div class="bw-thumb"></div></div>
                </div>
                <div class="toggle-row" @click="filterStar=!filterStar">
                  <span class="toggle-label main-font">ВЕРСИИ <span class="status-chip chip-star">*</span></span>
                  <div :class="['bw-toggle',{on:filterStar}]"><div class="bw-thumb"></div></div>
                </div>
                <div class="toggle-row" @click="showOut=!showOut">
                  <span class="toggle-label main-font">НЕТ <span class="status-chip chip-minus">-</span></span>
                  <div :class="['bw-toggle',{on:showOut}]"><div class="bw-thumb"></div></div>
                </div>
              </div>
            </transition>

            <!-- ФИЛЬТРЫ -->
            <transition name="pop">
              <div v-if="showFilters" class="popup-teleport" :style="[filterMenuStyle, popupThemeVars]">
                <div class="popup-section">
                  <span class="popup-label main-font">ПОЛ</span>
                  <div class="seg-ctrl">
                    <button v-for="g in genderOptions" :key="g.val" @click="activeGender=g.val" :class="['seg-btn main-font',{active:activeGender===g.val}]">{{ g.label }}</button>
                  </div>
                </div>
                <div class="popup-section">
                  <span class="popup-label main-font">ФАБРИКА</span>
                  <div class="seg-ctrl">
                    <button v-for="f in factoryOptions" :key="f.val" @click="activeFactory=f.val" :class="['seg-btn main-font',{active:activeFactory===f.val}]">{{ f.label }}</button>
                  </div>
                </div>
                <div class="popup-section">
                  <span class="popup-label main-font">КАЧЕСТВО</span>
                  <div class="seg-ctrl">
                    <button v-for="q in qualityOptions" :key="q.val" @click="activeQuality=q.val" :class="['seg-btn main-font',{active:activeQuality===q.val}]">{{ q.label }}</button>
                  </div>
                </div>
                <div class="popup-section">
                  <span class="popup-label main-font">ЦЕНА</span>
                  <div class="seg-ctrl">
                    <button v-for="s in sortOptions" :key="s.val" @click="sortBy=s.val" :class="['seg-btn main-font',{active:sortBy===s.val}]">
                      <span v-if="s.val==='id'">ID</span>
                      <span v-else>{{ s.label }}{{ s.val==='asc'?'▲':'▼' }}</span>
                    </button>
                  </div>
                </div>
                <div class="popup-section">
                  <span class="popup-label main-font">СТОЛБЦЫ</span>
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

    <!-- кастомный скроллбар -->
    <div v-if="!loading&&!errorMsg" class="scroll-track" ref="scrollTrack"
      @mousedown.prevent="startDrag" @touchstart.prevent="startDrag" @click="trackClick">
      <div class="scroll-thumb" :style="{ top:thumbTop+'%', height:thumbHeight+'%' }"></div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'

const currentTheme = ref('coal')
const currentFont = ref('nunito')
const showThemeMenu = ref(false)
const themeBtnRef = ref(null)
const themeMenuStyle = ref({})

// ── ВСЕ ТЕМЫ ────────────────────────────────────────────────────────────────
const themes = {
  // Тёмные
  coal:     { bg:'#19191b', text:'#e8e8ec', cardBg:'#111113', pillPrice:'#0b0b0d', pillMeta:'#16161a', pillName:'#23232a', pillSearch:'#0d0d10', border:'rgba(255,255,255,0.06)', dim:'#4a4a54', hoverBg:'#16161a', stickyBg:'rgba(13,13,15,0.97)', segBg:'#08080a', segActive:'#fff', segTxt:'#3a3a44', segTxtActive:'#000', btnBg:'#111113', btnBrd:'rgba(255,255,255,0.07)', liquidBg:'rgba(255,255,255,0.06)', liquidBrd:'rgba(255,255,255,0.12)', auraText:'#fff', panelBg:'#111113' },
  night:    { bg:'#0a0a0f', text:'#e0e0e8', cardBg:'#050508', pillPrice:'#030305', pillMeta:'#08080d', pillName:'#0d0d15', pillSearch:'#060609', border:'rgba(255,255,255,0.08)', dim:'#3a3a48', hoverBg:'#0e0e14', stickyBg:'rgba(5,5,8,0.97)', segBg:'#030306', segActive:'#e0e0e8', segTxt:'#2a2a38', segTxtActive:'#000', btnBg:'#050508', btnBrd:'rgba(255,255,255,0.08)', liquidBg:'rgba(255,255,255,0.06)', liquidBrd:'rgba(255,255,255,0.12)', auraText:'#fff', panelBg:'#0a0a0f' },
  marble:   { bg:'#2a2a30', text:'#f0f0f5', cardBg:'#1a1a1f', pillPrice:'#14141a', pillMeta:'#1e1e28', pillName:'#26263a', pillSearch:'#161620', border:'rgba(255,255,255,0.1)', dim:'#5a5a64', hoverBg:'#222228', stickyBg:'rgba(26,26,31,0.97)', segBg:'#101018', segActive:'#f0f0f5', segTxt:'#444', segTxtActive:'#000', btnBg:'#1a1a1f', btnBrd:'rgba(255,255,255,0.1)', liquidBg:'rgba(255,255,255,0.06)', liquidBrd:'rgba(255,255,255,0.12)', auraText:'#fff', panelBg:'#1e1e24' },
  graphite: { bg:'#1c1c1e', text:'#e5e5ea', cardBg:'#141416', pillPrice:'#0e0e10', pillMeta:'#18181c', pillName:'#212128', pillSearch:'#101014', border:'rgba(255,255,255,0.07)', dim:'#4a4a52', hoverBg:'#1a1a1e', stickyBg:'rgba(20,20,22,0.97)', segBg:'#0a0a0c', segActive:'#e5e5ea', segTxt:'#3a3a42', segTxtActive:'#000', btnBg:'#141416', btnBrd:'rgba(255,255,255,0.07)', liquidBg:'rgba(255,255,255,0.06)', liquidBrd:'rgba(255,255,255,0.12)', auraText:'#fff', panelBg:'#161618' },
  obsidian: { bg:'#0f0f11', text:'#d8d8e0', cardBg:'#080809', pillPrice:'#040405', pillMeta:'#0c0c0e', pillName:'#141418', pillSearch:'#08080b', border:'rgba(255,255,255,0.09)', dim:'#38384a', hoverBg:'#0c0c0f', stickyBg:'rgba(8,8,9,0.97)', segBg:'#040406', segActive:'#d8d8e0', segTxt:'#2e2e3e', segTxtActive:'#000', btnBg:'#080809', btnBrd:'rgba(255,255,255,0.09)', liquidBg:'rgba(255,255,255,0.06)', liquidBrd:'rgba(255,255,255,0.12)', auraText:'#fff', panelBg:'#0b0b0d' },
  // Светлые
  cloud:  { bg:'#f0f0f4', text:'#0f0f11', cardBg:'#fafafa', pillPrice:'#e0e0ea', pillMeta:'#e8e8f0', pillName:'#f0f0f6', pillSearch:'#e2e2ec', border:'rgba(0,0,0,0.07)', dim:'#aaa', hoverBg:'#f4f4f8', stickyBg:'rgba(240,240,244,0.97)', segBg:'#d4d4e0', segActive:'#111', segTxt:'#bbb', segTxtActive:'#fff', btnBg:'#e5e5ee', btnBrd:'rgba(0,0,0,0.07)', liquidBg:'rgba(0,0,0,0.04)', liquidBrd:'rgba(0,0,0,0.1)', auraText:'#111', panelBg:'#fafafa' },
  linen:  { bg:'#fafafa', text:'#0a0a0c', cardBg:'#ffffff', pillPrice:'#e5e5ef', pillMeta:'#ededf5', pillName:'#f5f5fb', pillSearch:'#e8e8f2', border:'rgba(0,0,0,0.06)', dim:'#b0b0b8', hoverBg:'#f6f6fa', stickyBg:'rgba(250,250,250,0.97)', segBg:'#d8d8e4', segActive:'#0a0a0c', segTxt:'#bbb', segTxtActive:'#fff', btnBg:'#ebebf2', btnBrd:'rgba(0,0,0,0.06)', liquidBg:'rgba(0,0,0,0.04)', liquidBrd:'rgba(0,0,0,0.1)', auraText:'#111', panelBg:'#fff' },
  pearl:  { bg:'#f5f5f7', text:'#0d0d0f', cardBg:'#fcfcfd', pillPrice:'#e3e3ed', pillMeta:'#ebebf3', pillName:'#f3f3f9', pillSearch:'#e6e6f0', border:'rgba(0,0,0,0.065)', dim:'#a8a8b2', hoverBg:'#f2f2f6', stickyBg:'rgba(245,245,247,0.97)', segBg:'#d6d6e2', segActive:'#0d0d0f', segTxt:'#bbb', segTxtActive:'#fff', btnBg:'#e8e8f0', btnBrd:'rgba(0,0,0,0.065)', liquidBg:'rgba(0,0,0,0.04)', liquidBrd:'rgba(0,0,0,0.1)', auraText:'#111', panelBg:'#fcfcfd' },
  snow:   { bg:'#ffffff', text:'#0c0c0e', cardBg:'#fefefe', pillPrice:'#e8e8f2', pillMeta:'#f0f0f8', pillName:'#f8f8fc', pillSearch:'#eaeaf4', border:'rgba(0,0,0,0.05)', dim:'#b8b8c0', hoverBg:'#f8f8fc', stickyBg:'rgba(255,255,255,0.97)', segBg:'#dcdce8', segActive:'#0c0c0e', segTxt:'#bbb', segTxtActive:'#fff', btnBg:'#eeeff6', btnBrd:'rgba(0,0,0,0.05)', liquidBg:'rgba(0,0,0,0.04)', liquidBrd:'rgba(0,0,0,0.1)', auraText:'#111', panelBg:'#fefefe' },
  cream:  { bg:'#fcfcfd', text:'#0b0b0d', cardBg:'#fefeff', pillPrice:'#e6e6f0', pillMeta:'#eeeff6', pillName:'#f6f6fa', pillSearch:'#e8e8f2', border:'rgba(0,0,0,0.055)', dim:'#b4b4bc', hoverBg:'#f6f6fa', stickyBg:'rgba(252,252,253,0.97)', segBg:'#dadae6', segActive:'#0b0b0d', segTxt:'#bbb', segTxtActive:'#fff', btnBg:'#ececf4', btnBrd:'rgba(0,0,0,0.055)', liquidBg:'rgba(0,0,0,0.04)', liquidBrd:'rgba(0,0,0,0.1)', auraText:'#111', panelBg:'#fefeff' }
}

const darkThemeIds = ['coal','night','marble','graphite','obsidian']
const lightThemeIds = ['cloud','linen','pearl','snow','cream']

const darkThemes = darkThemeIds.map(id => ({
  id,
  name: id.toUpperCase(),
  preview: { background: `linear-gradient(135deg, ${themes[id].bg} 0%, ${themes[id].cardBg} 100%)` }
}))
const lightThemes = lightThemeIds.map(id => ({
  id,
  name: id.toUpperCase(),
  preview: { background: `linear-gradient(135deg, ${themes[id].bg} 0%, ${themes[id].pillPrice} 100%)` }
}))

const fontOptions = [
  { id: 'nunito', family: 'Nunito, sans-serif' },
  { id: 'inter', family: 'Inter, sans-serif' },
  { id: 'manrope', family: 'Manrope, sans-serif' },
  { id: 'poppins', family: 'Poppins, sans-serif' },
  { id: 'montserrat', family: 'Montserrat, sans-serif' },
  { id: 'raleway', family: 'Raleway, sans-serif' },
  { id: 'lato', family: 'Lato, sans-serif' },
  { id: 'ubuntu', family: 'Ubuntu, sans-serif' },
  { id: 'opensans', family: 'Open Sans, sans-serif' },
  { id: 'roboto', family: 'Roboto, sans-serif' }
]

// ── Reactive theme CSS vars через :style ─────────────────────────────────────
const themeVars = computed(() => {
  const t = themes[currentTheme.value] || themes.coal
  return {
    '--bg': t.bg, '--text': t.text, '--card-bg': t.cardBg,
    '--pill-price': t.pillPrice, '--pill-meta': t.pillMeta, '--pill-name': t.pillName,
    '--pill-search': t.pillSearch, '--border': t.border, '--card-border': t.border,
    '--dim': t.dim, '--hover-bg': t.hoverBg, '--sticky-bg': t.stickyBg,
    '--seg-bg': t.segBg, '--seg-active': t.segActive, '--seg-txt': t.segTxt,
    '--seg-txt-active': t.segTxtActive, '--btn-bg': t.btnBg, '--btn-brd': t.btnBrd,
    '--liquid-bg': t.liquidBg, '--liquid-brd': t.liquidBrd, '--aura-text': t.auraText,
    '--panel-bg': t.panelBg, '--p-cols': activePriceCount.value
  }
})

// Для popup-ов (teleport) — передаём те же переменные через inline style
const popupThemeVars = computed(() => {
  const t = themes[currentTheme.value] || themes.coal
  return {
    '--panel-bg': t.panelBg, '--border': t.border, '--text': t.text,
    '--dim': t.dim, '--seg-bg': t.segBg, '--seg-active': t.segActive,
    '--seg-txt': t.segTxt, '--seg-txt-active': t.segTxtActive,
    '--bg': t.bg, '--card-bg': t.cardBg, '--btn-bg': t.btnBg, '--btn-brd': t.btnBrd,
    'color': t.text
  }
})

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
const anyMenuOpen = computed(() => showBrandMenu.value || showNewMenu.value || showFilters.value || showThemeMenu.value)

const genderOptions = [{ label: 'ВСЕ', val: 'ВСЕ' }, { label: 'МУЖ', val: 'm' }, { label: 'ЖЕН', val: 'w' }, { label: 'УНИ', val: 'y' }]
const factoryOptions = [{ label: 'ВСЕ', val: 'ВСЕ' }, { label: 'LUZI', val: 'LUZI' }, { label: 'EPS', val: 'EPS' }, { label: 'SELUZ', val: 'SELUZ' }]
const qualityOptions = [{ label: 'ВСЕ', val: 'ВСЕ' }, { label: 'TOP', val: 'TOP' }, { label: 'Q1', val: 'Q1' }, { label: 'Q2', val: 'Q2' }]
const sortOptions = [{ label: 'ID', val: 'id' }, { label: 'ЦЕНА', val: 'asc' }, { label: 'ЦЕНА', val: 'desc' }]

const togglePrice = (key) => {
  if (showPrices.value[key] && Object.values(showPrices.value).filter(Boolean).length === 1) return
  showPrices.value[key] = !showPrices.value[key]
}

const selectTheme = (themeId) => { currentTheme.value = themeId }
const selectFont = (fontId) => {
  currentFont.value = fontId
  const font = fontOptions.find(f => f.id === fontId)
  if (font) document.documentElement.style.setProperty('--main-font', font.family)
}

const toggleThemeMenu = async () => {
  if (showThemeMenu.value) { closeAllMenus(); return }
  closeAllMenus()
  await nextTick()
  themeMenuStyle.value = calcPopupStyle(themeBtnRef, 320)
  showThemeMenu.value = true
}

// ── Позиционирование popup ──────────────────────────────────────────────────
const brandBtnRef = ref(null)
const statusBtnRef = ref(null)
const filterBtnRef = ref(null)

const brandMenuStyle = ref({})
const statusMenuStyle = ref({})
const filterMenuStyle = ref({})

function calcPopupStyle(btnRef, popupWidth = 280) {
  const el = btnRef?.value
  if (!el) return {}
  const r = el.getBoundingClientRect()
  const vw = window.innerWidth
  const isMobile = vw <= 900
  if (isMobile) {
    const w = vw - 24
    return { position: 'fixed', top: (r.bottom + 6) + 'px', left: '12px', width: w + 'px', zIndex: 9999 }
  }
  // Центрируем под кнопкой, но не выходим за экран
  let left = r.left + r.width / 2 - popupWidth / 2
  if (left + popupWidth > vw - 12) left = vw - popupWidth - 12
  if (left < 12) left = 12
  return { position: 'fixed', top: (r.bottom + 6) + 'px', left: left + 'px', width: popupWidth + 'px', zIndex: 9999 }
}

const recalcMenuPositions = () => {
  if (showBrandMenu.value) brandMenuStyle.value = calcPopupStyle(brandBtnRef)
  if (showNewMenu.value) statusMenuStyle.value = calcPopupStyle(statusBtnRef)
  if (showFilters.value) filterMenuStyle.value = calcPopupStyle(filterBtnRef)
  if (showThemeMenu.value) themeMenuStyle.value = calcPopupStyle(themeBtnRef, 320)
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
const closeAllMenus = () => {
  showBrandMenu.value = false
  showNewMenu.value = false
  showFilters.value = false
  showThemeMenu.value = false
}

const toggleBrandSelection = (b) => {
  const i = selectedBrands.value.indexOf(b)
  if (i === -1) selectedBrands.value.push(b); else selectedBrands.value.splice(i, 1)
  closeAllMenus()
}
const clearBrands = () => { selectedBrands.value = []; closeAllMenus() }
const brandLabel = computed(() => {
  const n = selectedBrands.value.length
  return n === 0 ? 'БРЕНДЫ' : `${n} БРЕНД${n > 1 ? 'А' : ''}`
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
  const allFiltered = products.value.filter(p => {
    if (selectedBrands.value.length && !selectedBrands.value.includes(p.brand)) return false
    const q = searchQuery.value.toLowerCase()
    if (q && !p.name.toLowerCase().includes(q) && !p.brand.toLowerCase().includes(q)) return false
    if (activeGender.value !== 'ВСЕ' && p.gender !== activeGender.value) return false
    if (activeQuality.value !== 'ВСЕ' && p.quality !== activeQuality.value) return false
    if (activeFactory.value !== 'ВСЕ' && !p.factory.toUpperCase().includes(activeFactory.value)) return false
    if (filterPlus.value && !p.hasPlus) return false
    if (filterStar.value && !p.hasStar) return false
    return true
  })
  const p = allFiltered, n = p.length || 1
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

const getSex = (g) => ({ m:'МУЖ', w:'ЖЕН', y:'УНИ' }[g] || '—')
const open = (u) => window.open(u.startsWith('http') ? u : `https://${u}`, '_blank')

onMounted(() => {
  const st = document.createElement('style')
  st.id = 'bahur-global'
  st.textContent = 'html::-webkit-scrollbar{display:none!important}html{scrollbar-width:none!important;-ms-overflow-style:none!important}'
  document.head.appendChild(st)
  let meta = document.querySelector('meta[name=viewport]')
  if (!meta) { meta = document.createElement('meta'); meta.name='viewport'; document.head.appendChild(meta) }
  meta.content = 'width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no'

  selectFont(currentFont.value)
  loadData()

  window.addEventListener('scroll', updateThumb)
  window.addEventListener('resize', updateThumb)
  window.addEventListener('resize', recalcMenuPositions)
})
onUnmounted(() => {
  if (highlightInterval) clearInterval(highlightInterval)
  window.removeEventListener('scroll', updateThumb)
  window.removeEventListener('resize', updateThumb)
  window.removeEventListener('resize', recalcMenuPositions)
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap');
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@300;400;700&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Kollektif&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&family=Roboto:wght@400;700;900&family=Open+Sans:wght@400;600;700;800&family=Lato:wght@400;700;900&family=Poppins:wght@400;600;700;800&family=Montserrat:wght@400;600;700;800&family=Raleway:wght@400;600;700;800&family=Ubuntu:wght@400;700&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&display=swap');

.main-font  { font-family: var(--main-font, 'Nunito', sans-serif); }
.kollektif  { font-family: 'Kollektif', var(--main-font, 'Nunito'), sans-serif; }
.mono       { font-family: 'JetBrains Mono', monospace; }
.fw7 { font-weight: 700; }
.fw8 { font-weight: 800; }

/* ── ROOT ────────────────────────────────────────────── */
.bahur-terminal {
  min-height: 100vh;
  background: var(--bg);
  color: var(--text);
  font-family: var(--main-font, 'Nunito', sans-serif);
  touch-action: pan-y;
  transition: background 0.3s, color 0.3s;
}

::-webkit-scrollbar { width: 2px; height: 2px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: rgba(128,128,128,0.25); border-radius: 2px; }

.container {
  max-width: 1400px; margin: 0 auto;
  padding: 15px;
  box-sizing: border-box;
  overflow-x: hidden;
}

/* ── LOADING ──────────────────────────────────────────── */
.loading-overlay { position:fixed; inset:0; background:#000; z-index:9999; display:flex; justify-content:center; align-items:center; overflow:hidden; }
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
.header-manifest { margin-bottom:8px; }
.header-inner { display:flex; justify-content:space-between; align-items:center; padding:8px 0; gap:12px; }
.header-pill-btn { background:var(--card-bg); border:1px solid var(--border); color:var(--text); border-radius:18px; padding:6px 12px; font-size:10px; font-weight:800; cursor:pointer; display:flex; align-items:center; gap:4px; letter-spacing:0.8px; transition:all 0.2s; }
.header-pill-btn:hover { background:var(--text); color:var(--bg); }
.logo-bahur { font-family:'Kollektif','Nunito',sans-serif; font-size:20px; font-weight:900; letter-spacing:4px; color:var(--text); text-shadow:0 0 20px currentColor; flex:1; text-align:center; user-select:none; }

/* ── DASHBOARD — КОМПАКТНЫЕ КАРТОЧКИ ──────────────────── */
.dash-collapsible-wrapper { display:grid; grid-template-rows:0fr; transition:grid-template-rows 0.3s ease; }
.dash-collapsible-wrapper.open { grid-template-rows:1fr; margin-bottom:10px; }
.dash-inner-content { overflow:hidden; }
.dash-grid { display:flex; flex-wrap:wrap; gap:8px; }
.stat-card { border:1px solid var(--border); padding:14px; background:var(--card-bg); border-left:3px solid var(--text); border-radius:10px; transition: background 0.3s, border-color 0.3s; }
.stat-compact { flex:1 1 160px; min-width:140px; max-width:240px; }
.stat-wide { flex:1 1 100%; }
.d-label { display:block; font-size:8px; font-weight:800; color:var(--dim); margin-bottom:8px; letter-spacing:1.5px; text-transform:uppercase; }
.v { font-size:20px; font-weight:800; }
.stat-sub { display:flex; gap:10px; margin-top:6px; font-size:10px; color:var(--dim); font-weight:700; }
.stat-sub b { color:var(--text); margin-left:3px; }
.avg-price-compact { display:flex; flex-direction:column; gap:2px; }
.ap-item { font-size:11px; color:var(--dim); font-weight:700; }
.ap-item .val { color:var(--text); font-weight:800; margin-left:4px; }
.q-list-mini { display:flex; flex-direction:column; gap:6px; }
.q-row-mini {}
.q-meta-mini { display:flex; justify-content:space-between; font-size:9px; font-weight:700; margin-bottom:3px; text-transform:uppercase; }
.q-track-neon { height:3px; background:var(--border); border-radius:2px; overflow:hidden; }
.q-fill-neon { height:100%; background:var(--text); transition: background 0.3s; }
.q-track-neon-thick { height:5px; background:var(--border); border-radius:3px; overflow:hidden; margin-top:8px; }
.q-fill-neon-thick { height:100%; background:var(--text); transition: background 0.3s; }
.top-header-center { display:flex; justify-content:center; margin-bottom:8px; }
.top-switch-btn-subtle { background:transparent; border:1px solid var(--border); color:var(--text); padding:4px 10px; border-radius:20px; font-size:9px; font-weight:700; cursor:pointer; }
.btn-subtle-label { color:var(--dim); }
.top-list-scroll-container { max-height:120px; overflow-y:auto; overflow-x:hidden; display:flex; flex-direction:column; gap:3px; scrollbar-width:thin; scrollbar-color:rgba(128,128,128,0.3) transparent; }
.top-list-scroll-container::-webkit-scrollbar { width:3px; }
.top-list-scroll-container::-webkit-scrollbar-thumb { background:rgba(128,128,128,0.4); border-radius:2px; }
.top-row-compact { display:grid; grid-template-columns:minmax(0,2fr) auto minmax(0,1fr); align-items:center; gap:8px; padding:3px 0; border-bottom:1px solid var(--border); min-width:0; }
.top-row-compact:last-child { border-bottom:none; }
.tr-left-main { display:flex; align-items:center; min-width:0; overflow:hidden; }
.top-num { color:var(--dim); margin-right:4px; font-weight:700; flex-shrink:0; font-size:10px; }
.top-name { overflow:hidden; white-space:nowrap; text-overflow:ellipsis; font-weight:700; min-width:0; font-size:11px; text-transform:uppercase; }
.tr-mid-graph { display:flex; align-items:center; min-width:0; }
.mini-bar-track { width:100%; height:3px; background:var(--border); border-radius:2px; overflow:hidden; }
.mini-bar-fill { height:100%; background:var(--text); }
.tr-right-meta { display:flex; align-items:center; gap:3px; flex-shrink:0; }
.badge-mini { border:1px solid var(--border); padding:1px 5px; font-size:8px; border-radius:4px; font-weight:700; text-transform:uppercase; }
.percent-badge { background:var(--pill-meta); border-color:transparent; font-weight:800; }
.op-5 { opacity:0.5; }

/* ── STICKY NAV ───────────────────────────────────────── */
.sticky-nav-group {
  position: sticky; top: 0; z-index: 100;
  background: var(--sticky-bg);
  backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
  box-shadow: 0 4px 24px rgba(0,0,0,0.3), 0 1px 0 var(--border);
  border-radius: 0 0 20px 20px;
  overflow: visible;
  padding: 0 5px;
  transition: background 0.3s;
}
.controls-luxury { padding: 12px 0 0; display:flex; flex-direction:column; gap:8px; }

/* Поиск */
.search-block { padding:0 0 8px; border-bottom:1px solid var(--border); }
.search-wrap-inline {
  display:flex; align-items:center; width:100%; height:42px;
  background:var(--pill-search); border-radius:12px; position:relative;
  border:2px solid transparent; transition:border-color 0.2s, background 0.3s;
  box-sizing:border-box;
}
.search-wrap-inline:focus-within { border-color:var(--text); }
.search-wrap-inline .s-ico { position:absolute; left:14px; width:14px; height:14px; color:var(--dim); pointer-events:none; flex-shrink:0; }
.search-wrap-inline .s-inp { width:100%; height:100%; background:transparent; border:none; outline:none; color:var(--text); padding:0 14px 0 38px; font-size:11px; font-weight:800; letter-spacing:1.1px; box-sizing:border-box; }
.search-wrap-inline .s-inp::placeholder { color:var(--dim); opacity:0.6; }
.search-wrap-inline .s-clr { display:none; }

/* кнопки-триггеры */
.ctrl-row {
  display: flex; gap: 6px; padding: 0 0 10px;
  overflow-x: auto; overflow-y: visible;
  scrollbar-width: none; -webkit-overflow-scrolling: touch;
}
.ctrl-row::-webkit-scrollbar { display: none; }
.ctrl-item { flex-shrink: 0; }
.main-ctrl-btn {
  background: var(--btn-bg); border: 1px solid var(--btn-brd);
  color: var(--text); padding: 8px 14px; border-radius: 18px;
  font-size: 10px; cursor: pointer;
  display: flex; align-items: center; gap: 5px;
  white-space: nowrap; transition: all 0.2s; letter-spacing:0.7px; font-weight:700;
}
.main-ctrl-btn:hover { filter: brightness(1.25); }
.main-ctrl-btn.active { background: var(--text); color: var(--bg); border-color: transparent; }
.arr { width: 9px; height: 9px; opacity: 0.5; flex-shrink: 0; }
.truncate { max-width: 120px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

.click-overlay { position:fixed; top:0; left:0; width:100vw; height:100vh; z-index:98; background:transparent; }

/* ── POPUP ────────────────────────────────────────────── */
.popup-teleport {
  background: var(--panel-bg);
  border: 1px solid var(--border);
  border-radius: 16px; padding: 14px;
  box-shadow: 0 20px 60px rgba(0,0,0,0.75);
  display: flex; flex-direction: column; gap: 10px;
  max-height: calc(100vh - 120px); overflow-y: auto;
  box-sizing: border-box;
  font-family: var(--main-font, 'Nunito', sans-serif);
  transition: background 0.3s, border-color 0.3s, color 0.3s;
}

.pop-enter-active, .pop-leave-active { transition: all 0.18s cubic-bezier(0.16,1,0.3,1); }
.pop-enter-from, .pop-leave-to { opacity:0; transform:translateY(-6px) scale(0.97); }

/* ── DESIGN POPUP — 3 ряда ────────────────────────────── */
.design-popup { min-width:200px; max-width:320px; gap:8px; padding:12px; }
.design-row { display:flex; gap:5px; justify-content:center; }
.theme-swatch {
  width:36px; height:36px; border-radius:10px; border:2px solid transparent;
  cursor:pointer; transition:all 0.15s; padding:0; flex-shrink:0;
}
.theme-swatch:hover { border-color:rgba(128,128,128,0.4); transform:scale(1.08); }
.theme-swatch.active { border-color:var(--text); box-shadow:0 0 10px rgba(128,128,128,0.3); }
.font-row { gap:4px; flex-wrap:wrap; }
.font-swatch {
  width:36px; height:36px; border-radius:10px; border:1px solid var(--border);
  background:var(--seg-bg); color:var(--text); cursor:pointer;
  font-size:13px; font-weight:700; display:flex; align-items:center; justify-content:center;
  transition:all 0.15s; padding:0; flex-shrink:0;
}
.font-swatch:hover { border-color:rgba(128,128,128,0.4); transform:scale(1.08); }
.font-swatch.active { background:var(--text); color:var(--bg); border-color:var(--text); }

/* popup contents */
.search-input-box { width:100%; }
.popup-input { width:100%; background:var(--seg-bg); border:1px solid var(--border); padding:9px 10px; border-radius:8px; color:var(--text); font-size:12px; outline:none; box-sizing:border-box; font-weight:700; letter-spacing:0.5px; transition: background 0.3s, color 0.3s; }
.popup-input::placeholder { opacity:0.5; color:var(--dim); }
.brands-scroll-area { max-height:260px; overflow-y:auto; scrollbar-width:thin; scrollbar-color:rgba(128,128,128,0.5) transparent; }
.brands-scroll-area::-webkit-scrollbar { width:4px; }
.brands-scroll-area::-webkit-scrollbar-track { background:var(--seg-bg); border-radius:2px; }
.brands-scroll-area::-webkit-scrollbar-thumb { background:rgba(128,128,128,0.6); border-radius:2px; }
.brands-list { display:flex; flex-direction:column; gap:3px; }
.brand-btn { display:flex; justify-content:space-between; align-items:center; background:transparent; color:var(--text); border:none; padding:9px 10px; border-radius:6px; cursor:pointer; font-size:12px; font-weight:700; width:100%; text-align:left; transition:background 0.12s; letter-spacing:0.3px; }
.brand-btn:hover { background:rgba(128,128,128,0.1); }
.all-brand { font-weight:800; border-bottom:1px solid var(--border); border-radius:0; margin-bottom:4px; padding-bottom:10px; }
.brand-left { display:flex; align-items:center; gap:7px; overflow:hidden; }
.brand-txt { white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:180px; text-transform:uppercase; }
.no-results { font-size:11px; color:var(--dim); padding:8px 10px; }

.toggle-row { display:flex; justify-content:space-between; align-items:center; cursor:pointer; padding:8px 0; border-bottom:1px solid var(--border); gap:8px; }
.toggle-row:last-child { border-bottom:none; }
.toggle-label { font-size:11px; color:var(--text); font-weight:800; display:flex; align-items:center; gap:6px; letter-spacing:0.8px; }
.bw-toggle { width:34px; height:19px; border:1px solid var(--border); border-radius:20px; position:relative; flex-shrink:0; transition: border-color 0.3s; }
.bw-thumb { width:13px; height:13px; background:var(--text); border-radius:50%; position:absolute; left:2px; top:2px; transition:transform 0.3s, background 0.3s; }
.bw-toggle.on .bw-thumb { transform:translateX(15px); }
.status-chip { display:inline-flex; align-items:center; justify-content:center; width:18px; height:18px; border-radius:5px; font-size:12px; font-weight:900; }
.chip-plus { background:rgba(0,168,107,0.2); color:#00a86b; }
.chip-star { background:rgba(160,32,240,0.2); color:#a020f0; }
.chip-minus { background:rgba(253,70,89,0.2); color:#fd4659; }

.popup-section { margin-bottom:2px; }
.popup-label { display:block; font-size:9px; font-weight:800; color:var(--dim); margin-bottom:5px; letter-spacing:1.2px; }
.seg-ctrl { display:flex; background:var(--seg-bg); padding:3px; border-radius:8px; transition: background 0.3s; }
.seg-btn { flex:1; background:transparent; border:none; color:var(--seg-txt); padding:6px 0; font-size:10px; font-weight:800; border-radius:5px; cursor:pointer; transition:background 0.1s,color 0.1s; letter-spacing:0.5px; }
.seg-btn.active { background:var(--seg-active); color:var(--seg-txt-active); box-shadow:0 1px 4px rgba(0,0,0,0.5); }

/* ── ШАПКА ТАБЛИЦЫ ────────────────────────────────────── */
.tbl-head {
  display: grid;
  grid-template-columns: 40px 1fr repeat(3, 52px) calc(var(--p-cols) * 52px);
  align-items: stretch;
  padding: 3px 0 5px;
  box-sizing: border-box;
}
.h-id { display:flex; align-items:center; justify-content:center; }
.h-name { padding: 3px; display:flex; align-items:stretch; }
.h-pill { padding: 3px; display:flex; align-items:stretch; justify-content:center; }
.h-prices { display:grid; padding: 3px; gap: 4px; }
.h-prices .h-pill { padding: 0; }
.hp {
  display: flex; align-items: center; justify-content: center;
  width: 100%; height: 40px;
  border-radius: 9px;
  font-size: 8px; font-weight: 800; letter-spacing: 0.8px;
  color: var(--dim); box-sizing: border-box; white-space: nowrap;
  transition: background 0.3s;
}
.meta-hp { background: var(--pill-meta); }
.price-hp { background: var(--pill-price); }
.name-hp { background: var(--pill-search); display:flex; align-items:center; justify-content:flex-start; padding-left:12px; font-size:9px; letter-spacing:1.2px; border:2px solid transparent; }

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
  transition: transform 0.18s, box-shadow 0.18s, background 0.3s;
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

.c-id { display:flex; flex-direction:column; align-items:center; justify-content:center; gap:1px; padding:2px; }
.id-num { font-size:13px; font-weight:900; color:var(--dim); line-height:1; }
.id-sym { font-size:15px; font-weight:900; line-height:1; }

.c-name { display:flex; align-items:stretch; padding:3px; }
.pill-name {
  background: var(--pill-name);
  border-radius: 11px; padding: 8px 12px;
  width: 100%; display:flex; flex-direction:column; justify-content:center;
  min-height: 40px; box-sizing:border-box;
  transition: background 0.3s;
}
.brand-code { font-size:9px; font-weight:400; opacity:0.4; display:block; text-transform:uppercase; letter-spacing:1px; }
.scent-title { font-weight:700; font-size:16px; line-height:1.2; letter-spacing:0.2px; text-transform:uppercase; }
.mob-meta { display:none; margin-top:5px; gap:3px; align-items:center; flex-wrap:wrap; }
.mob-badge { background:var(--pill-meta); border-radius:6px; padding:3px 5px; font-size:8px; font-weight:800; text-transform:uppercase; transition: background 0.3s; }

.c-meta { display:flex; align-items:stretch; padding:3px; }
.pill-meta {
  background: var(--pill-meta);
  border-radius: 9px; padding: 0 3px;
  font-size: 9px; font-weight: 800;
  width: 100%; height: 100%; min-height: 40px;
  display: flex; align-items: center; justify-content: center;
  box-sizing: border-box; text-align: center;
  transition: background 0.3s;
}

.c-prices { display:grid; gap:4px; padding:3px; align-items:stretch; }
.pill-price {
  background: var(--pill-price);
  border-radius: 9px; padding: 0 2px;
  font-size: 11px; font-weight: 800;
  width: 100%; min-height: 40px;
  display: flex; align-items: center; justify-content: center;
  box-sizing: border-box;
  transition: background 0.3s;
}

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

/* ── ДЕСКТОП ──────────────────────────────────────────── */
@media (min-width: 901px) {
  .search-block { max-width:100%; }
  .dash-grid { flex-wrap:nowrap; }
  .stat-compact { max-width:none; }
}

/* ── МОБИЛЬ ───────────────────────────────────────────── */
@media (max-width: 900px) {
  .scroll-track { display: none !important; }

  .dash-grid { flex-direction:column; }
  .stat-compact { max-width:100%; }

  .sticky-nav-group {
    margin-left: -15px; margin-right: -15px;
    padding-left: 15px; padding-right: 15px;
    border-radius: 0 0 16px 16px;
  }

  .search-block { max-width:100%; }
  .search-wrap-inline { height:40px; }
  .search-wrap-inline .s-inp { font-size:11px; }

  .ctrl-row {
    overflow-x: visible;
    display: grid; grid-template-columns: repeat(3, 1fr);
    gap: 6px; min-width: 0;
  }
  .ctrl-item { flex-shrink: unset; }
  .main-ctrl-btn { width: 100%; padding: 10px 6px; justify-content: center; font-size:10px; }
  .arr { display: none; }
  .truncate { max-width: 100%; }

  .header-manifest { margin-bottom:5px; }
  .header-pill-btn { padding:6px 12px; font-size:10px; }

  .grid-table { min-width: 100%; }
  .desk-only { display: none !important; }
  .mob-meta { display: flex !important; }

  .tbl-head {
    grid-template-columns: 32px 1fr calc(var(--p-cols) * 38px);
    padding: 2px 0 4px;
  }
  .tbl-row {
    grid-template-columns: 32px 1fr calc(var(--p-cols) * 38px);
    padding: 3px; border-radius: 12px;
  }

  .c-id { padding: 0; }
  .id-num { font-size: 10px; }
  .id-sym { font-size: 12px; }

  .c-name { padding: 2px 2px 2px 1px; }
  .pill-name { padding: 5px 8px 5px 6px; border-radius: 8px; min-height: 0; }
  .scent-title { font-size: 11px; }
  .brand-code { font-size: 7px; }
  .mob-meta { margin-top: 3px; gap: 3px; }
  .mob-badge { padding: 2px 5px; font-size: 7px; border-radius: 5px; }

  .c-prices { padding: 2px; gap: 2px; }
  .pill-price { font-size: 10px; min-height: 0; border-radius: 7px; padding: 0 1px; }

  .h-name { padding: 2px; }
  .name-hp { padding-left:8px; font-size:8px; border-radius:8px; }
  .h-prices { padding: 2px; gap: 2px; }

  .aura-txt { font-size: 8px; letter-spacing: 1.5px; }

  .container { padding-right: 15px; }

  .design-popup { min-width:auto; max-width:calc(100vw - 24px); }
  .theme-swatch { width:32px; height:32px; }
  .font-swatch { width:32px; height:32px; font-size:11px; }
}
</style>
