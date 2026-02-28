import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'

PersistentStorage.persistProp('localWardrobeRecords', '[]')

// ─── Design Tokens ─────────────────────────────────────────────────────────
const C_PRIMARY: string = '#EC13EC'      // magenta primary
const C_PRIMARY_LIGHT: string = '#FCE7FC' // primary light background
const C_BG: string = '#F8F6F8'           // light background
const C_CARD: string = '#FFFFFF'         // card white
const C_INK: string = '#181118'          // near-black text
const C_SUB: string = '#896189'          // purple-ish sub text
const C_MUTED: string = '#C2C2C2'        // muted / inactive icons
const C_LINE: string = '#EBEBEB'         // divider line

const R_XL: number = 20
const R_L: number = 14
const R_M: number = 10
const PAD: number = 16
const GAP: number = 10

// ─── Interfaces ─────────────────────────────────────────────────────────────
interface FeedCard {
  id: number
  imageUrl: string
  avatarUrl: string
  userName: string
  tag: string
  cardHeight: number
}

interface WardrobeItem {
  id: number
  imageUrl: string
  name: string
  category: string
  local: boolean
}

interface LocalWardrobeRecord {
  id: number
  imageUrl: string
  name: string
  category: string
}

interface ClosetItem {
  id: number
  imageUrl: string
  name: string
  categoryIndex: number
}

// ───────────────────────────────────────────────────────────────────────────
// CommunityPage
// ───────────────────────────────────────────────────────────────────────────
@Component
struct CommunityPage {
  @State searchText: string = ''
  @State selectedTag: number = 0
  @State likedIds: number[] = []
  private tags: string[] = ['全部', '#夏日氛围', '#通勤穿搭', '#街头风', '#约会夜']
  private cards: FeedCard[] = [
    {
      id: 1,
      imageUrl: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=700',
      avatarUrl: 'https://i.pravatar.cc/80?img=48',
      userName: 'Anna K.',
      tag: '#夏日氛围',
      cardHeight: 276
    },
    {
      id: 2,
      imageUrl: 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=700',
      avatarUrl: 'https://i.pravatar.cc/80?img=33',
      userName: 'Mike Ross',
      tag: '#通勤穿搭',
      cardHeight: 232
    },
    {
      id: 3,
      imageUrl: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=700',
      avatarUrl: 'https://i.pravatar.cc/80?img=52',
      userName: 'Leo D.',
      tag: '#街头风',
      cardHeight: 308
    },
    {
      id: 4,
      imageUrl: 'https://images.unsplash.com/photo-1464863979621-258859e62245?w=700',
      avatarUrl: 'https://i.pravatar.cc/80?img=28',
      userName: 'Sarah J.',
      tag: '#约会夜',
      cardHeight: 256
    }
  ]

  private getFilteredCards(): FeedCard[] {
    const keyword: string = this.searchText.trim().toLowerCase()
    const currentTag: string = this.tags[this.selectedTag]
    return this.cards.filter((item: FeedCard) => {
      const matchTag: boolean = this.selectedTag === 0 || item.tag === currentTag
      const matchText: boolean = keyword.length === 0 ||
        item.userName.toLowerCase().includes(keyword) ||
        item.tag.toLowerCase().includes(keyword)
      return matchTag && matchText
    })
  }

  private isLiked(id: number): boolean {
    return this.likedIds.includes(id)
  }

  private toggleLike(id: number): void {
    this.likedIds = this.isLiked(id)
      ? this.likedIds.filter((v: number) => v !== id)
      : [...this.likedIds, id]
  }

  private showToast(msg: string): void {
    try { this.getUIContext().getPromptAction().openToast({ message: msg }) } catch (_e) {}
  }

  @Builder
  private FeedCardView(item: FeedCard) {
    Column() {
      // Image + overlays
      Stack({ alignContent: Alignment.TopEnd }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(item.imageUrl)
            .width('100%')
            .height(item.cardHeight)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: R_XL, topRight: R_XL })

          // Bottom gradient
          Column()
            .width('100%')
            .height(90)
            .linearGradient({
              direction: GradientDirection.Top,
              colors: [['#00000000', 0], ['#000000A0', 1]]
            })
            .borderRadius({ topLeft: R_XL, topRight: R_XL })

          // Avatar + username
          Row({ space: 6 }) {
            Image(item.avatarUrl)
              .width(24)
              .height(24)
              .borderRadius(12)
              .border({ color: '#FFFFFFCC', width: 1.5 })
            Text(item.userName)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .padding({ left: 12, bottom: 12 })
        }

        // Like button
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(32)
            .height(32)
            .borderRadius(16)
            .backgroundColor(this.isLiked(item.id) ? '#FFD6F5' : '#00000028')
          Text(this.isLiked(item.id) ? '♥' : '♡')
            .fontSize(14)
            .fontColor(this.isLiked(item.id) ? C_PRIMARY : '#FFFFFFCC')
        }
        .width(32)
        .height(32)
        .padding({ top: 10, right: 10 })
        .onClick(() => { this.toggleLike(item.id) })
      }
      .clip(true)
      .borderRadius({ topLeft: R_XL, topRight: R_XL })

      // "Try this Look" button
      Row({ space: 6 }) {
        Text('👗')
          .fontSize(13)
        Text('试试这套')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(C_PRIMARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 10, bottom: 10 })
      .backgroundColor(C_CARD)
      .borderRadius({ bottomLeft: R_XL, bottomRight: R_XL })
      .onClick(() => { this.showToast('试试这套搭配！') })
    }
    .width('100%')
    .backgroundColor(C_CARD)
    .borderRadius(R_XL)
    .shadow({ radius: 10, color: '#18000000', offsetX: 0, offsetY: 4 })
    .clip(true)
  }

  build() {
    Column({ space: 0 }) {
      // ── Header ────────────────────────────────────────────────
      Row() {
        Column({ space: 2 }) {
          Text('VibeFit 社区')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(C_INK)
          Text('发现热门 AI 穿搭')
            .fontSize(13)
            .fontColor(C_SUB)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        // Notification button with dot
        Stack({ alignContent: Alignment.TopEnd }) {
          Column()
            .width(38)
            .height(38)
            .borderRadius(19)
            .backgroundColor(C_BG)
          Column({ space: 0 }) {
            Column()
              .width(14)
              .height(12)
              .borderRadius({ topLeft: 7, topRight: 7 })
              .backgroundColor('#00000000')
              .border({ color: C_INK, width: 1.5 })
            Column()
              .width(6)
              .height(3)
              .borderRadius({ bottomLeft: 3, bottomRight: 3 })
              .backgroundColor('#00000000')
              .border({ color: C_INK, width: 1.5 })
          }
          .offset({ x: -9, y: -9 })
          // Red dot
          Column()
            .width(8)
            .height(8)
            .borderRadius(4)
            .backgroundColor(C_PRIMARY)
            .border({ color: C_CARD, width: 1.5 })
        }
        .width(38)
        .height(38)
        .onClick(() => { this.showToast('暂无新通知') })
      }
      .width('100%')
      .padding({ left: PAD, right: PAD, top: 16, bottom: 10 })

      // ── Search bar ────────────────────────────────────────────
      Search({ value: this.searchText, placeholder: '搜索风格、氛围或创作者...' })
        .width('100%')
        .height(44)
        .backgroundColor(C_CARD)
        .borderRadius(R_L)
        .shadow({ radius: 6, color: '#0A000000', offsetX: 0, offsetY: 2 })
        .margin({ left: PAD, right: PAD, bottom: 10 })
        .onChange((v: string) => { this.searchText = v })

      // ── Tag filter row ─────────────────────────────────────────
      Scroll() {
        Row({ space: 7 }) {
          ForEach(this.tags, (tag: string, idx: number) => {
            Text(tag)
              .fontSize(13)
              .fontWeight(this.selectedTag === idx ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.selectedTag === idx ? '#FFFFFF' : C_SUB)
              .backgroundColor(this.selectedTag === idx ? C_PRIMARY : C_CARD)
              .borderRadius(20)
              .border({ color: this.selectedTag === idx ? '#00000000' : C_LINE, width: 1 })
              .padding({ left: 16, right: 16, top: 7, bottom: 7 })
              .shadow({
                radius: 4,
                color: this.selectedTag === idx ? '#40EC13EC' : '#08000000',
                offsetX: 0,
                offsetY: 2
              })
              .onClick(() => { this.selectedTag = idx })
          })
        }
        .padding({ left: PAD, right: PAD })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(44)

      // ── Feed cards ─────────────────────────────────────────────
      Scroll() {
        if (this.getFilteredCards().length === 0) {
          Column({ space: 6 }) {
            Text('未找到结果')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(C_INK)
            Text('试试其他关键词')
              .fontSize(13)
              .fontColor(C_SUB)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 80 })
        } else {
          Grid() {
            ForEach(this.getFilteredCards(), (item: FeedCard) => {
              GridItem() { this.FeedCardView(item) }
            })
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(GAP)
          .rowsGap(GAP)
          .padding({ left: PAD, right: PAD, top: 6, bottom: 16 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(C_BG)
  }
}

// ───────────────────────────────────────────────────────────────────────────
// TryOnRoomPage
// ───────────────────────────────────────────────────────────────────────────
@Component
struct TryOnRoomPage {
  @State selectedCategory: number = 0
  @State selectedItemId: number = 1
  @State actionMode: boolean = false
  @State initializedFromStorage: boolean = false
  @State pressedAI: boolean = false
  @State pressedImport: string = ''
  @State pressedWardrobeId: number = -1
  @StorageLink('localWardrobeRecords') localWardrobeRecords: string = '[]'
  private categories: string[] = ['上装', '下装', '鞋履', '配饰']

  @State private topsItems: WardrobeItem[] = [
    { id: 1, imageUrl: 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?w=300', name: '白衬衫', category: '上装', local: false },
    { id: 2, imageUrl: 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=300', name: '真丝吊带', category: '上装', local: false }
  ]
  @State private bottomsItems: WardrobeItem[] = [
    { id: 3, imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=300', name: '阔腿裤', category: '下装', local: false },
    { id: 4, imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=300', name: '牛仔裤', category: '下装', local: false }
  ]
  @State private shoesItems: WardrobeItem[] = [
    { id: 5, imageUrl: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=300', name: '白色运动鞋', category: '鞋履', local: false },
    { id: 6, imageUrl: 'https://images.unsplash.com/photo-1515347619252-60a4bf4fff4f?w=300', name: '粗跟鞋', category: '鞋履', local: false }
  ]
  @State private accItems: WardrobeItem[] = [
    { id: 7, imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300', name: '托特包', category: '配饰', local: false },
    { id: 8, imageUrl: 'https://images.unsplash.com/photo-1601121141461-9d6647bef0a1?w=300', name: '项链', category: '配饰', local: false }
  ]

  aboutToAppear(): void {
    if (this.initializedFromStorage) { return }
    this.initializedFromStorage = true
    this.restoreLocalRecords()
  }

  private getCurrentItems(): WardrobeItem[] {
    if (this.selectedCategory === 0) { return this.topsItems }
    if (this.selectedCategory === 1) { return this.bottomsItems }
    if (this.selectedCategory === 2) { return this.shoesItems }
    return this.accItems
  }

  private getNextId(): number {
    const all: WardrobeItem[] = [...this.topsItems, ...this.bottomsItems, ...this.shoesItems, ...this.accItems]
    return all.length === 0 ? 1 : Math.max(...all.map((i: WardrobeItem) => i.id)) + 1
  }

  private insertItem(item: WardrobeItem): void {
    if (item.category === '上装') { this.topsItems = [item, ...this.topsItems] }
    else if (item.category === '下装') { this.bottomsItems = [item, ...this.bottomsItems] }
    else if (item.category === '鞋履') { this.shoesItems = [item, ...this.shoesItems] }
    else { this.accItems = [item, ...this.accItems] }
  }

  private saveLocalRecords(): void {
    const all: WardrobeItem[] = [...this.topsItems, ...this.bottomsItems, ...this.shoesItems, ...this.accItems]
    const local: LocalWardrobeRecord[] = all
      .filter((i: WardrobeItem) => i.local)
      .map((i: WardrobeItem): LocalWardrobeRecord => ({ id: i.id, imageUrl: i.imageUrl, name: i.name, category: i.category }))
    this.localWardrobeRecords = JSON.stringify(local)
  }

  private restoreLocalRecords(): void {
    try {
      const records: LocalWardrobeRecord[] = JSON.parse(this.localWardrobeRecords) as LocalWardrobeRecord[]
      records.forEach((r: LocalWardrobeRecord) => {
        this.insertItem({ id: r.id, imageUrl: r.imageUrl, name: r.name, category: r.category, local: true })
      })
    } catch (_e) { this.localWardrobeRecords = '[]' }
  }

  private async requestMediaPermission(): Promise<boolean> {
    try {
      const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext
      const atm = abilityAccessCtrl.createAtManager()
      const perms: Array<Permissions> = ['ohos.permission.READ_MEDIA']
      const res = await atm.requestPermissionsFromUser(ctx, perms)
      return res.authResults.length > 0 && res.authResults[0] === 0
    } catch (_e) { return false }
  }

  private showToast(msg: string): void {
    try { this.getUIContext().getPromptAction().openToast({ message: msg }) } catch (_e) {}
  }

  private async importByPicker(fromCamera: boolean): Promise<void> {
    try {
      if (!await this.requestMediaPermission()) {
        this.showToast('相册权限未授权')
        return
      }
      const picker = new photoAccessHelper.PhotoViewPicker()
      const opts = new photoAccessHelper.PhotoSelectOptions()
      opts.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      opts.maxSelectNumber = 1
      const extOpts = opts as Record<string, Object>
      extOpts['isPhotoTakingSupported'] = fromCamera
      const res = await picker.select(opts)
      if (!res?.photoUris?.length) { return }
      const item: WardrobeItem = {
        id: this.getNextId(),
        imageUrl: res.photoUris[0],
        name: this.categories[this.selectedCategory],
        category: this.categories[this.selectedCategory],
        local: true
      }
      this.insertItem(item)
      this.selectedItemId = item.id
      this.saveLocalRecords()
      this.showToast('导入成功')
    } catch (_e) { this.showToast('导入失败') }
  }

  private selectCategory(idx: number): void {
    this.selectedCategory = idx
    const list = this.getCurrentItems()
    if (list.length > 0) { this.selectedItemId = list[0].id }
  }

  private getSelectedItemName(): string {
    const list = this.getCurrentItems()
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === this.selectedItemId) { return list[i].name }
    }
    return list.length > 0 ? list[0].name : '未选择'
  }

  private getPreviewUrl(): string {
    const list = this.getCurrentItems()
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === this.selectedItemId) { return list[i].imageUrl }
    }
    return 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1000'
  }

  build() {
    Column({ space: 0 }) {

      // ── 1. Top nav bar ─────────────────────────────────────────
      Row() {
        Text('试衣间')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(C_INK)

        Blank()

        // Camera / import toggle button
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(38)
            .height(38)
            .borderRadius(19)
            .backgroundColor(this.actionMode ? C_PRIMARY : C_CARD)
            .shadow({ radius: 6, color: '#12000000', offsetX: 0, offsetY: 2 })
          Column({ space: 2 }) {
            Column()
              .width(14)
              .height(10)
              .borderRadius(3)
              .backgroundColor('#00000000')
              .border({ color: this.actionMode ? '#FFFFFF' : C_INK, width: 1.5 })
            Column()
              .width(6)
              .height(2)
              .backgroundColor(this.actionMode ? '#FFFFFF' : C_INK)
              .borderRadius(1)
          }
        }
        .width(38)
        .height(38)
        .margin({ right: 10 })
        .onClick(() => { this.actionMode = !this.actionMode })

        // Share button
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(38)
            .height(38)
            .borderRadius(19)
            .backgroundColor(C_CARD)
            .shadow({ radius: 6, color: '#12000000', offsetX: 0, offsetY: 2 })
          Column({ space: 0 }) {
            Column()
              .width(0)
              .height(0)
              .borderStyle(BorderStyle.Solid)
              .borderWidth({ left: 5, right: 5, bottom: 8 })
              .borderColor({ left: '#00000000', right: '#00000000', bottom: C_INK })
            Column()
              .width(2)
              .height(6)
              .backgroundColor(C_INK)
            Row() {
              Column().width(14).height(2).backgroundColor(C_INK).borderRadius(1)
            }
          }
        }
        .width(38)
        .height(38)
        .onClick(() => { this.showToast('分享功能即将上线') })
      }
      .width('100%')
      .padding({ left: PAD, right: PAD, top: 14, bottom: 10 })
      .backgroundColor(C_BG)

      // ── 2. Preview area ─────────────────────────────────────────
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(this.getPreviewUrl())
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)

        Column()
          .width('100%')
          .height(88)
          .linearGradient({
            direction: GradientDirection.Top,
            colors: [['#00000000', 0], ['#000000AA', 1]]
          })

        Row() {
          Column({ space: 3 }) {
            Text(this.categories[this.selectedCategory])
              .fontSize(11)
              .fontColor('#FFFFFFAA')
            Text(this.getSelectedItemName())
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text(this.actionMode ? '收起' : '+ 导入')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.actionMode ? C_INK : '#FFFFFF')
            .backgroundColor(this.actionMode ? '#FFFFFF' : '#FFFFFF28')
            .borderRadius(R_M)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .onClick(() => { this.actionMode = !this.actionMode })
        }
        .width('100%')
        .padding({ left: PAD, right: PAD, bottom: 14 })
      }
      .width('100%')
      .height(220)
      .clip(true)

      // ── 3. Wardrobe area ──────────────────────────────────────
      Column({ space: 0 }) {

        // Wardrobe header
        Row() {
          Text('我的数字衣橱')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(C_INK)
          Blank()
          // Import button (pill)
          Row({ space: 4 }) {
            Text('+')
              .fontSize(16)
              .fontColor(C_PRIMARY)
              .fontWeight(FontWeight.Bold)
            Text('导入')
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor(C_PRIMARY)
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(C_PRIMARY_LIGHT)
          .borderRadius(20)
          .onClick(() => { this.actionMode = !this.actionMode })
        }
        .width('100%')
        .padding({ left: PAD, right: PAD, top: 14, bottom: 8 })

        // Import panel (collapsible)
        if (this.actionMode) {
          Row({ space: GAP }) {
            Button({ type: ButtonType.Normal }) {
              Text('拍照')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .layoutWeight(1)
            .height(46)
            .backgroundColor(C_INK)
            .borderRadius(R_M)
            .stateEffect(false)
            .scale({
              x: this.pressedImport === 'camera' ? 0.96 : 1.0,
              y: this.pressedImport === 'camera' ? 0.96 : 1.0
            })
            .animation({ duration: 100, curve: Curve.EaseOut })
            .onTouch((e: TouchEvent) => {
              this.pressedImport = e.type === TouchType.Down ? 'camera' : ''
            })
            .onClick(async () => {
              this.actionMode = false
              await this.importByPicker(true)
            })

            Button({ type: ButtonType.Normal }) {
              Text('相册')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(C_INK)
            }
            .layoutWeight(1)
            .height(46)
            .backgroundColor('#EEEEEE')
            .borderRadius(R_M)
            .stateEffect(false)
            .scale({
              x: this.pressedImport === 'album' ? 0.96 : 1.0,
              y: this.pressedImport === 'album' ? 0.96 : 1.0
            })
            .animation({ duration: 100, curve: Curve.EaseOut })
            .onTouch((e: TouchEvent) => {
              this.pressedImport = e.type === TouchType.Down ? 'album' : ''
            })
            .onClick(async () => {
              this.actionMode = false
              await this.importByPicker(false)
            })
          }
          .width('100%')
          .padding({ left: PAD, right: PAD, top: 4, bottom: 4 })
        }

        // Category tabs (underline style)
        Row({ space: 0 }) {
          ForEach(this.categories, (cat: string, idx: number) => {
            Column({ space: 0 }) {
              Text(cat)
                .fontSize(14)
                .fontWeight(this.selectedCategory === idx ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.selectedCategory === idx ? C_INK : C_MUTED)
                .padding({ left: 12, right: 12, top: 12, bottom: 10 })

              Column()
                .width('60%')
                .height(2)
                .backgroundColor(this.selectedCategory === idx ? C_PRIMARY : '#00000000')
                .borderRadius(1)
            }
            .alignItems(HorizontalAlign.Center)
            .layoutWeight(1)
            .onClick(() => { this.selectCategory(idx) })
          })
        }
        .width('100%')
        .backgroundColor(C_CARD)

        Column()
          .width('100%')
          .height(1)
          .backgroundColor(C_LINE)

        // Wardrobe horizontal list
        List({ space: 10 }) {
          ForEach(this.getCurrentItems(), (item: WardrobeItem) => {
            ListItem() {
              Column({ space: 6 }) {
                Stack({ alignContent: Alignment.TopEnd }) {
                  Image(item.imageUrl)
                    .width(100)
                    .height(120)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(R_L)
                    .border({
                      color: this.selectedItemId === item.id ? C_PRIMARY : C_LINE,
                      width: this.selectedItemId === item.id ? 2 : 1
                    })
                    .scale({
                      x: this.pressedWardrobeId === item.id ? 0.96 : 1.0,
                      y: this.pressedWardrobeId === item.id ? 0.96 : 1.0
                    })
                    .animation({ duration: 100, curve: Curve.EaseOut })

                  if (this.selectedItemId === item.id) {
                    Text('✓')
                      .fontSize(10)
                      .fontColor('#FFFFFF')
                      .width(20)
                      .height(20)
                      .textAlign(TextAlign.Center)
                      .backgroundColor(C_PRIMARY)
                      .borderRadius(10)
                      .margin({ top: 6, right: 6 })
                  }
                }

                Text(item.name)
                  .fontSize(12)
                  .fontColor(this.selectedItemId === item.id ? C_PRIMARY : C_SUB)
                  .fontWeight(this.selectedItemId === item.id ? FontWeight.Bold : FontWeight.Normal)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width(100)
                  .textAlign(TextAlign.Center)
              }
              .onTouch((e: TouchEvent) => {
                this.pressedWardrobeId = e.type === TouchType.Down ? item.id : -1
              })
              .onClick(() => { this.selectedItemId = item.id })
            }
          })
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
        .padding({ left: PAD, right: PAD, top: 12, bottom: 10 })
        .layoutWeight(1)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(C_CARD)

      // ── 4. AI Generate button ─────────────────────────────────
      Column() {
        Row({ space: 0 }) {
          Text(this.getCurrentItems().length + ' 件可选')
            .fontSize(12)
            .fontColor(C_MUTED)
            .layoutWeight(1)

          Text(this.getSelectedItemName())
            .fontSize(12)
            .fontColor(C_SUB)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: 120 })
        }
        .width('100%')
        .padding({ bottom: 8 })

        Button({ type: ButtonType.Normal }) {
          Row({ space: 7 }) {
            Text('✦')
              .fontSize(12)
              .fontColor('#FFFFFF99')
            Text('AI 生成试穿')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
        }
        .width('100%')
        .height(52)
        .linearGradient({ direction: GradientDirection.Right, colors: [[C_PRIMARY, 0], ['#C000C0', 1]] })
        .borderRadius(R_L)
        .stateEffect(false)
        .scale({
          x: this.pressedAI ? 0.97 : 1.0,
          y: this.pressedAI ? 0.97 : 1.0
        })
        .animation({ duration: 120, curve: Curve.EaseOut })
        .onTouch((e: TouchEvent) => {
          this.pressedAI = e.type === TouchType.Down
        })
        .onClick(() => {
          const list = this.getCurrentItems()
          if (list.length > 0) {
            this.selectedItemId = list[(this.selectedItemId + this.selectedCategory) % list.length].id
          }
          this.showToast('AI 生成中...')
        })
      }
      .width('100%')
      .padding({ left: PAD, right: PAD, top: 8, bottom: 20 })
      .backgroundColor(C_CARD)
      .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: -2 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(C_BG)
  }
}

// ───────────────────────────────────────────────────────────────────────────
// UserProfilePage
// ───────────────────────────────────────────────────────────────────────────
@Component
struct UserProfilePage {
  @State selectedCategory: number = 0
  @State showAllCloset: boolean = false
  private categories: string[] = ['全部单品', '上装', '下装', '鞋履']
  // categoryIndex: 1=Tops, 2=Bottoms, 3=Shoes
  private closetItems: ClosetItem[] = [
    { id: 1, imageUrl: 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=500', name: '牛仔外套', categoryIndex: 1 },
    { id: 2, imageUrl: 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=500', name: '白色亚麻衬衫', categoryIndex: 1 },
    { id: 3, imageUrl: 'https://images.unsplash.com/photo-1515347619252-60a4bf4fff4f?w=500', name: '蓝色高跟鞋', categoryIndex: 3 },
    { id: 4, imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500', name: '橙色毛衣', categoryIndex: 1 },
    { id: 5, imageUrl: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=500', name: '印花围巾', categoryIndex: 3 },
  ]

  private getFilteredItems(): ClosetItem[] {
    const list = this.selectedCategory === 0
      ? this.closetItems
      : this.closetItems.filter((i: ClosetItem) => i.categoryIndex === this.selectedCategory)
    return this.showAllCloset ? list : list.slice(0, 4)
  }

  private showToast(msg: string): void {
    try { this.getUIContext().getPromptAction().openToast({ message: msg }) } catch (_e) {}
  }

  @Builder
  private Stat(value: string, label: string) {
    Column({ space: 3 }) {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(C_INK)
      Text(label)
        .fontSize(11)
        .fontColor(C_SUB)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 16, bottom: 16 })
  }

  build() {
    Scroll() {
      Column({ space: 0 }) {

        // ── Top action bar ────────────────────────────────────────
        Row() {
          Text('个人主页')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(C_INK)
          Blank()
          // Settings button
          Stack({ alignContent: Alignment.Center }) {
            Column()
              .width(38)
              .height(38)
              .borderRadius(19)
              .backgroundColor(C_CARD)
              .shadow({ radius: 6, color: '#12000000', offsetX: 0, offsetY: 2 })
            // Gear icon (two concentric circles)
            Stack({ alignContent: Alignment.Center }) {
              Column()
                .width(16)
                .height(16)
                .borderRadius(8)
                .backgroundColor('#00000000')
                .border({ color: C_INK, width: 1.5 })
              Column()
                .width(5)
                .height(5)
                .borderRadius(2.5)
                .backgroundColor(C_INK)
            }
            .width(18)
            .height(18)
          }
          .width(38)
          .height(38)
          .onClick(() => { this.showToast('设置') })
        }
        .width('100%')
        .padding({ left: PAD, right: PAD, top: 16, bottom: 6 })

        // ── Profile section ───────────────────────────────────────
        Column({ space: 0 }) {
          // Avatar with gradient ring
          Stack({ alignContent: Alignment.Center }) {
            // Gradient ring (outermost)
            Column()
              .width(132)
              .height(132)
              .borderRadius(66)
              .linearGradient({
                direction: GradientDirection.RightBottom,
                colors: [[C_PRIMARY, 0], ['#8A00A0', 1]]
              })
            // White gap ring
            Column()
              .width(124)
              .height(124)
              .borderRadius(62)
              .backgroundColor(C_CARD)
            // Avatar image
            Image('https://i.pravatar.cc/220?img=47')
              .width(116)
              .height(116)
              .borderRadius(58)
              .objectFit(ImageFit.Cover)
          }
          .width(132)
          .height(132)
          .margin({ bottom: 6 })

          // Trendsetter badge
          Row({ space: 4 }) {
            Text('◇')
              .fontSize(11)
              .fontColor(C_PRIMARY)
            Text('潮流先锋')
              .fontSize(11)
              .fontWeight(FontWeight.Bold)
              .fontColor(C_PRIMARY)
              .letterSpacing(0.5)
          }
          .backgroundColor(C_CARD)
          .borderRadius(20)
          .border({ color: C_PRIMARY_LIGHT, width: 1 })
          .padding({ left: 12, right: 12, top: 5, bottom: 5 })
          .shadow({ radius: 4, color: '#18000000', offsetX: 0, offsetY: 2 })
          .margin({ bottom: 16 })

          // User info
          Column({ space: 4 }) {
            Text('艾利克斯·里维拉')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(C_INK)
            Text('@alex.vibe • 旧金山')
              .fontSize(13)
              .fontColor(C_SUB)
          }
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 20 })

          // Edit Profile button
          Row({ space: 7 }) {
            Text('编辑资料')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('✎')
              .fontSize(14)
              .fontColor('#FFFFFFBB')
          }
          .padding({ left: 28, right: 28, top: 13, bottom: 13 })
          .backgroundColor(C_INK)
          .borderRadius(30)
          .shadow({ radius: 14, color: '#30000000', offsetX: 0, offsetY: 6 })
          .onClick(() => { this.showToast('编辑资料') })
          .margin({ bottom: 24 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 20 })
        .backgroundColor(C_BG)

        // ── Stats card ────────────────────────────────────────────
        Row() {
          this.Stat('42', '穿搭')
          Column().width(1).height(32).backgroundColor(C_LINE)
          this.Stat('1.2k', '粉丝')
          Column().width(1).height(32).backgroundColor(C_LINE)
          this.Stat('85', '收藏')
        }
        .width('calc(100% - 32vp)')
        .backgroundColor(C_CARD)
        .borderRadius(R_L)
        .margin({ left: PAD, right: PAD, bottom: 20 })
        .shadow({ radius: 8, color: '#0C000000', offsetX: 0, offsetY: 3 })

        // ── Digital Closet ─────────────────────────────────────────
        Column({ space: 12 }) {
          // Section header
          Row() {
            Text('我的数字衣橱')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(C_INK)
            Blank()
            Text(this.showAllCloset ? '收起' : '查看全部')
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor(C_PRIMARY)
              .onClick(() => { this.showAllCloset = !this.showAllCloset })
          }
          .width('100%')

          // Filter tags
          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.categories, (cat: string, idx: number) => {
                Text(cat)
                  .fontSize(13)
                  .fontWeight(this.selectedCategory === idx ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(this.selectedCategory === idx ? '#FFFFFF' : C_SUB)
                  .backgroundColor(this.selectedCategory === idx ? C_INK : C_BG)
                  .borderRadius(20)
                  .padding({ left: 18, right: 18, top: 8, bottom: 8 })
                  .onClick(() => { this.selectedCategory = idx })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)

          // 2-column closet grid
          Grid() {
            ForEach(this.getFilteredItems(), (item: ClosetItem) => {
              GridItem() {
                Stack({ alignContent: Alignment.BottomEnd }) {
                  Image(item.imageUrl)
                    .width('100%')
                    .aspectRatio(0.75)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(R_L)

                  // Checkroom badge
                  Stack({ alignContent: Alignment.Center }) {
                    Column()
                      .width(32)
                      .height(32)
                      .borderRadius(16)
                      .backgroundColor('#FFFFFFD0')
                    Text('👗')
                      .fontSize(13)
                  }
                  .width(32)
                  .height(32)
                  .margin({ bottom: 8, right: 8 })
                }
                .borderRadius(R_L)
                .clip(true)
                .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 3 })
              }
            })

            // Add Item cell
            GridItem() {
              Column({ space: 8 }) {
                Stack({ alignContent: Alignment.Center }) {
                  Column()
                    .width(44)
                    .height(44)
                    .borderRadius(22)
                    .backgroundColor(C_PRIMARY_LIGHT)
                  Text('+')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(C_PRIMARY)
                }
                .width(44)
                .height(44)

                Text('添加单品')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(C_SUB)
              }
              .width('100%')
              .aspectRatio(0.75)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor(C_CARD)
              .borderRadius(R_L)
              .border({ color: C_LINE, width: 2, style: BorderStyle.Dashed })
              .onClick(() => { this.showToast('添加新单品') })
            }
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(GAP)
          .rowsGap(GAP)
        }
        .padding({ left: PAD, right: PAD, top: 24, bottom: 100 })
        .backgroundColor(C_CARD)
        .borderRadius({ topLeft: 28, topRight: 28 })
        .shadow({ radius: 16, color: '#0A000000', offsetX: 0, offsetY: -6 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(C_BG)
    .scrollBar(BarState.Off)
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Index — Root component with bottom TabBar
// ───────────────────────────────────────────────────────────────────────────
@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  @State pressedTabIndex: number = -1

  @Builder
  private TabIcon(type: string, active: boolean) {
    Stack({ alignContent: Alignment.Center }) {
      if (type === 'community') {
        Grid() {
          ForEach(['a', 'b', 'c', 'd'], (_s: string) => {
            GridItem() {
              Column()
                .width(5)
                .height(5)
                .borderRadius(1.5)
                .backgroundColor(active ? C_PRIMARY : C_MUTED)
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .columnsGap(3)
        .rowsGap(3)
        .width(16)
        .height(16)
      } else if (type === 'tryon') {
        // Shirt outline
        Column({ space: 1 }) {
          Row({ space: 2 }) {
            Column()
              .width(5)
              .height(5)
              .borderRadius({ topLeft: 3, bottomRight: 3 })
              .backgroundColor('#00000000')
              .border({ color: active ? C_PRIMARY : C_MUTED, width: 1.5 })
            Column()
              .width(5)
              .height(5)
              .borderRadius({ topRight: 3, bottomLeft: 3 })
              .backgroundColor('#00000000')
              .border({ color: active ? C_PRIMARY : C_MUTED, width: 1.5 })
          }
          Column()
            .width(14)
            .height(10)
            .borderRadius({ bottomLeft: 3, bottomRight: 3 })
            .backgroundColor('#00000000')
            .border({ color: active ? C_PRIMARY : C_MUTED, width: 1.5 })
        }
        .width(18)
        .height(18)
      } else {
        // Person icon
        Column({ space: 2 }) {
          Circle()
            .width(8)
            .height(8)
            .fill(active ? C_PRIMARY : C_MUTED)
          Column()
            .width(14)
            .height(7)
            .borderRadius({ topLeft: 7, topRight: 7 })
            .backgroundColor('#00000000')
            .border({ color: active ? C_PRIMARY : C_MUTED, width: 1.5 })
        }
        .width(18)
        .height(18)
      }
    }
    .width(20)
    .height(20)
  }

  @Builder
  private TabItem(label: string, type: string, index: number) {
    Column({ space: 4 }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(40)
          .height(28)
          .borderRadius(14)
          .backgroundColor(this.currentIndex === index ? C_PRIMARY_LIGHT : '#00000000')
          .animation({ duration: 180, curve: Curve.EaseOut })

        this.TabIcon(type, this.currentIndex === index)
      }
      .width(40)
      .height(28)
      .scale({
        x: this.pressedTabIndex === index ? 0.92 : 1.0,
        y: this.pressedTabIndex === index ? 0.92 : 1.0
      })
      .animation({ duration: 100, curve: Curve.EaseOut })

      Text(label)
        .fontSize(10)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? C_PRIMARY : C_MUTED)
    }
    .width(80)
    .padding({ top: 6, bottom: 6 })
    .onTouch((e: TouchEvent) => {
      this.pressedTabIndex = e.type === TouchType.Down ? index : -1
    })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() { CommunityPage() }
          .tabBar(this.TabItem('社区', 'community', 0))

        TabContent() { TryOnRoomPage() }
          .tabBar(this.TabItem('试衣', 'tryon', 1))

        TabContent() { UserProfilePage() }
          .tabBar(this.TabItem('我的', 'profile', 2))
      }
      .onChange((idx: number) => { this.currentIndex = idx })
      .barHeight(76)
      .barBackgroundColor(C_CARD)
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
      .divider({ strokeWidth: 0, color: '#00000000', startMargin: 0, endMargin: 0 })
      .scrollable(false)
      .width('100%')
      .height('100%')

      // Center floating FAB (magenta primary)
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(52)
          .height(52)
          .borderRadius(26)
          .linearGradient({ direction: GradientDirection.Bottom, colors: [[C_PRIMARY, 0], ['#C000C0', 1]] })
          .shadow({ radius: 18, color: '#50EC13EC', offsetX: 0, offsetY: 8 })
        Text('+')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ bottom: 2 })
      }
      .width(52)
      .height(52)
      .borderRadius(26)
      .offset({ y: -26 })
      .onClick(() => { this.currentIndex = 1 })
    }
    .width('100%')
    .height('100%')
  }
}
