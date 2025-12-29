import svgPaths from "./svg-c9lk6172rh";

function Frame() {
  return (
    <div className="absolute inset-0 overflow-clip" data-name="Frame">
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <img alt="" className="absolute left-0 max-w-none size-full top-0" src="a6746284f9589fbc91a471b3324f42c0ddd746b7.png" />
      </div>
    </div>
  );
}

function Frame1() {
  return (
    <div className="absolute inset-[31px_323px_207px_17px] overflow-clip rounded-[100px]" data-name="Frame">
      <Frame />
    </div>
  );
}

function AutoLayoutHorizontal() {
  return (
    <div className="box-border content-stretch flex items-start max-w-[104.47px] overflow-clip pl-0 pr-[9.47px] py-0 relative shrink-0" data-name="Auto Layout Horizontal">
      <div className="flex flex-col font-['Roboto:Bold',sans-serif] font-bold justify-center leading-[0] relative shrink-0 text-[#0f1419] text-[14px] text-nowrap" style={{ fontVariationSettings: "'wdth' 100" }}>
        <p className="leading-[19px] whitespace-pre">Mask Of Dual…</p>
      </div>
    </div>
  );
}

function AutoLayoutHorizontal1() {
  return (
    <div className="content-stretch flex items-center overflow-clip relative shrink-0" data-name="Auto Layout Horizontal">
      <AutoLayoutHorizontal />
    </div>
  );
}

function Group() {
  return (
    <div className="absolute inset-[7.29%]" data-name="Group">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 15 15">
        <g id="Group">
          <path d={svgPaths.p28359cf0} fill="var(--fill-0, #1D9BF0)" id="Vector" />
        </g>
      </svg>
    </div>
  );
}

function Frame2() {
  return (
    <div className="relative shrink-0 size-[17.5px]" data-name="Frame">
      <Group />
    </div>
  );
}

function AutoLayoutHorizontal2() {
  return (
    <div className="content-stretch flex items-start justify-center max-h-[19px] max-w-[19px] overflow-clip relative shrink-0 w-[17.5px]" data-name="Auto Layout Horizontal">
      <Frame2 />
    </div>
  );
}

function AutoLayoutHorizontal3() {
  return (
    <div className="box-border content-stretch flex items-start pl-[2px] pr-0 py-0 relative shrink-0" data-name="Auto Layout Horizontal">
      <AutoLayoutHorizontal2 />
    </div>
  );
}

function AutoLayoutHorizontal4() {
  return (
    <div className="content-stretch flex items-center max-w-[123.97px] relative shrink-0 w-[123.97px]" data-name="Auto Layout Horizontal">
      <AutoLayoutHorizontal1 />
      <AutoLayoutHorizontal3 />
    </div>
  );
}

function AutoLayoutHorizontal5() {
  return (
    <div className="absolute content-stretch flex items-center left-[74px] max-w-[257.5px] top-[35px]" data-name="Auto Layout Horizontal">
      <AutoLayoutHorizontal4 />
    </div>
  );
}

function AutoLayoutHorizontal6() {
  return (
    <div className="absolute bottom-0 box-border content-stretch flex items-start left-[101.17px] pl-[4px] pr-[3.78px] py-0 right-[16.58px] top-0" data-name="Auto Layout Horizontal">
      <div className="flex flex-col font-['Roboto:Regular',sans-serif] font-normal justify-center leading-[0] relative shrink-0 text-[#536471] text-[14px] text-nowrap" style={{ fontVariationSettings: "'wdth' 100" }}>
        <p className="leading-[19px] whitespace-pre">·</p>
      </div>
    </div>
  );
}

function AutoLayoutHorizontal7() {
  return (
    <div className="box-border content-stretch flex items-start max-w-[101.17px] overflow-clip pl-0 pr-[5.17px] py-0 relative shrink-0 w-[101.17px]" data-name="Auto Layout Horizontal">
      <div className="flex flex-col font-['Roboto:Regular',sans-serif] font-normal justify-center leading-[0] relative shrink-0 text-[#536471] text-[14px] text-nowrap" style={{ fontVariationSettings: "'wdth' 100" }}>
        <p className="leading-[19px] whitespace-pre">@Maskofdual…</p>
      </div>
    </div>
  );
}

function AutoLayoutVertical() {
  return (
    <div className="absolute bottom-0 content-stretch flex flex-col items-start left-0 max-w-[129.53px] right-[28.36px] top-0" data-name="Auto Layout Vertical">
      <AutoLayoutHorizontal7 />
    </div>
  );
}

function AutoLayoutHorizontal8() {
  return (
    <div className="absolute bottom-0 box-border content-stretch flex items-start left-[112.95px] pl-0 pr-[0.58px] py-0 right-0 top-0" data-name="Auto Layout Horizontal">
      <div className="flex flex-col font-['Roboto:Regular',sans-serif] font-normal justify-center leading-[0] relative shrink-0 text-[#536471] text-[14px] text-nowrap" style={{ fontVariationSettings: "'wdth' 100" }}>
        <p className="leading-[19px] whitespace-pre">3h</p>
      </div>
    </div>
  );
}

function Frame3() {
  return (
    <div className="h-[19px] relative shrink-0 w-[129.53px]" data-name="Frame">
      <AutoLayoutHorizontal6 />
      <AutoLayoutVertical />
      <AutoLayoutHorizontal8 />
    </div>
  );
}

function AutoLayoutHorizontal9() {
  return (
    <div className="absolute content-stretch flex items-start left-[74px] top-[56px]" data-name="Auto Layout Horizontal">
      <Frame3 />
    </div>
  );
}

function Group3() {
  return (
    <div className="absolute contents left-[74px] top-[35px]">
      <AutoLayoutHorizontal5 />
      <AutoLayoutHorizontal9 />
    </div>
  );
}

function Group5() {
  return (
    <div className="absolute contents left-[17px] top-[31px]">
      <Frame1 />
      <Group3 />
    </div>
  );
}

function Group1() {
  return (
    <div className="absolute inset-[41.67%_12.5%]" data-name="Group">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 17 4">
        <g id="Group">
          <path d={svgPaths.p6242100} fill="var(--fill-0, #536471)" id="Vector" />
        </g>
      </svg>
    </div>
  );
}

function Frame4() {
  return (
    <div className="absolute left-[calc(50%+168px)] size-[22px] top-[31px] translate-x-[-50%]" data-name="Frame">
      <Group1 />
    </div>
  );
}

function Group4() {
  return (
    <div className="absolute contents left-[17px] top-[31px]">
      <Group5 />
      <Frame4 />
      <div className="absolute flex flex-col font-['Roboto:Regular',sans-serif] font-normal justify-center leading-[0] left-[17px] text-[#0f1419] text-[14px] top-[120.5px] translate-y-[-50%] w-[345px]" style={{ fontVariationSettings: "'wdth' 100" }}>
        <p className="leading-[19px]">Aiming to be the best truth always results in suppression of others regardless if they know they are wrong or not.</p>
      </div>
      <div className="absolute flex flex-col font-['Roboto:Regular',sans-serif] font-normal justify-center leading-[19px] left-[17px] text-[#0f1419] text-[14px] top-[179px] translate-y-[-50%] w-[369px]" style={{ fontVariationSettings: "'wdth' 100" }}>
        <p className="mb-0">It is better to let the population figure this out</p>
        <p>instead of suppressing information you deem to be lies.</p>
      </div>
    </div>
  );
}

function Group6() {
  return (
    <div className="absolute contents left-[31px] top-[235px]">
      <p className="absolute capitalize font-['Roboto:Regular',sans-serif] font-normal leading-[normal] left-[57px] text-[14px] text-nowrap text-white top-[235px] whitespace-pre" style={{ fontVariationSettings: "'wdth' 100" }}>
        4.2k
      </p>
      <div className="absolute inset-[82.17%_86.86%_11.61%_7.99%]" data-name="Vector">
        <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 20 18">
          <path d={svgPaths.p27cffaf0} fill="var(--fill-0, white)" id="Vector" />
        </svg>
      </div>
    </div>
  );
}

function Group7() {
  return (
    <div className="absolute contents left-[17px] top-[223px]">
      <div className="absolute backdrop-blur-[5px] backdrop-filter bg-[#d6775c] h-[42px] left-[17px] rounded-[28px] top-[223px] w-[83px]">
        <div aria-hidden="true" className="absolute border border-[rgba(255,255,255,0)] border-solid inset-[-1px] pointer-events-none rounded-[29px]" />
      </div>
      <Group6 />
    </div>
  );
}

function Group2() {
  return (
    <div className="absolute contents left-[17px] top-[223px]">
      <Group7 />
    </div>
  );
}

function Group8() {
  return (
    <div className="absolute contents left-[125px] top-[234px]">
      <div className="absolute inset-[81.82%_62.63%_11.19%_32.22%]" data-name="Vector">
        <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 20 20">
          <path d={svgPaths.p2428ca80} fill="var(--fill-0, #8E8E8E)" id="Vector" />
        </svg>
      </div>
      <p className="absolute capitalize font-['Roboto:Regular',sans-serif] font-normal leading-[normal] left-[152px] text-[#8e8e8e] text-[14px] text-nowrap top-[235px] whitespace-pre" style={{ fontVariationSettings: "'wdth' 100" }}>
        273
      </p>
    </div>
  );
}

function Group9() {
  return (
    <div className="absolute contents left-[109px] top-[223px]">
      <div className="absolute backdrop-blur-[5px] backdrop-filter bg-white border border-[#e6e6e6] border-solid h-[42px] left-[109px] rounded-[28px] top-[223px] w-[83px]" />
      <Group8 />
    </div>
  );
}

function Group10() {
  return (
    <div className="absolute contents left-[288px] top-[223px]">
      <div className="absolute backdrop-blur-[5px] backdrop-filter bg-white border border-[#e6e6e6] border-solid h-[42px] left-[288px] rounded-[28px] top-[223px] w-[83px]" />
    </div>
  );
}

function Group11() {
  return (
    <div className="absolute contents left-[302px] top-[235px]">
      <div className="absolute inset-[82.17%_17.3%_11.23%_77.84%]" data-name="Vector">
        <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 19 19">
          <path d={svgPaths.p39ad9c00} fill="var(--fill-0, #8E8E8E)" id="Vector" />
        </svg>
      </div>
      <p className="absolute capitalize font-['Roboto:Regular',sans-serif] font-normal leading-[normal] left-[325px] text-[#8e8e8e] text-[12px] text-nowrap top-[237px] whitespace-pre" style={{ fontVariationSettings: "'wdth' 100" }}>
        Share
      </p>
    </div>
  );
}

function Group12() {
  return (
    <div className="absolute contents left-[288px] top-[223px]">
      <Group10 />
      <Group11 />
    </div>
  );
}

export default function Group13() {
  return (
    <div className="relative size-full">
      <div className="absolute bg-neutral-50 h-[286px] left-1/2 rounded-[10px] top-0 translate-x-[-50%] w-[388px]" />
      <Group4 />
      <Group2 />
      <Group9 />
      <Group12 />
    </div>
  );
}