import svgPaths from "./svg-jgg1iae82p";

function VuesaxBoldHome() {
  return (
    <div className="absolute contents inset-0" data-name="vuesax/bold/home-2">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 25 25">
        <g id="home-2">
          <path d={svgPaths.p3c873280} id="Vector" stroke="var(--stroke-0, white)" strokeWidth="2" />
          <path d={svgPaths.p505e900} id="Vector_2" opacity="0" stroke="var(--stroke-0, white)" />
        </g>
      </svg>
    </div>
  );
}

function Home() {
  return (
    <div className="relative shrink-0 size-[25px]" data-name="home">
      <VuesaxBoldHome />
    </div>
  );
}

function Frame() {
  return (
    <div className="absolute box-border content-stretch flex flex-col gap-[6px] inset-[24.68%_84.84%_16.88%_4.16%] items-center justify-center p-[10px]">
      <div aria-hidden="true" className="absolute border border-[rgba(11,74,245,0)] border-solid inset-0 pointer-events-none" />
      <Home />
    </div>
  );
}

function VuesaxLinearAdd() {
  return (
    <div className="absolute contents inset-0" data-name="vuesax/linear/add">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 19 19">
        <g id="add">
          <path d="M4.75 9.5H14.25" id="Vector" stroke="var(--stroke-0, black)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" />
          <path d="M9.5 14.25V4.75" id="Vector_2" stroke="var(--stroke-0, black)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" />
          <g id="Vector_3" opacity="0"></g>
        </g>
      </svg>
    </div>
  );
}

function VuesaxLinearAdd1() {
  return (
    <div className="relative shrink-0 size-[19px]" data-name="vuesax/linear/add">
      <VuesaxLinearAdd />
    </div>
  );
}

function NavigationMenuHome() {
  return (
    <div className="absolute bg-white box-border content-stretch flex flex-col gap-[6px] items-center justify-center left-[174px] p-[18px] rounded-[71px] top-[14px]" data-name="navigation/menu - home">
      <VuesaxLinearAdd1 />
    </div>
  );
}

function NavigationMenuAnalysis() {
  return (
    <div className="absolute left-[250px] size-[60px] top-[11px]" data-name="navigation/menu - analysis">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 60 60">
        <g id="navigation/menu - analysis">
          <path d={svgPaths.p1ea17a00} id="Vector" stroke="var(--stroke-0, white)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" />
        </g>
      </svg>
    </div>
  );
}

function Group2() {
  return (
    <div className="absolute contents left-[250px] top-[11px]">
      <NavigationMenuAnalysis />
    </div>
  );
}

function NavigationMenuAnalysis1() {
  return (
    <div className="absolute left-[93px] size-[60px] top-[11px]" data-name="navigation/menu - analysis">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 60 60">
        <g id="navigation/menu - analysis">
          <path d={svgPaths.p19144d80} fill="var(--fill-0, white)" id="Vector" />
        </g>
      </svg>
    </div>
  );
}

function Group5() {
  return (
    <div className="absolute contents left-[93px] top-[11px]">
      <NavigationMenuAnalysis1 />
    </div>
  );
}

function Group3() {
  return (
    <div className="absolute contents left-[93px] top-[11px]">
      <Group5 />
    </div>
  );
}

function Group4() {
  return (
    <div className="absolute contents left-[17px] top-[11px]">
      <Frame />
      <NavigationMenuHome />
      <Group2 />
      <Group3 />
    </div>
  );
}

function VuesaxLinearUser() {
  return (
    <div className="absolute contents inset-0" data-name="vuesax/linear/user">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 20 20">
        <g id="user">
          <path d={svgPaths.p1039200} id="Vector" stroke="var(--stroke-0, white)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" />
          <path d={svgPaths.p19362f00} id="Vector_2" stroke="var(--stroke-0, white)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" />
          <path d="M19.5 0.5V19.5H0.5V0.5H19.5Z" id="Vector_3" opacity="0" stroke="var(--stroke-0, white)" />
        </g>
      </svg>
    </div>
  );
}

function User() {
  return (
    <div className="[grid-area:1_/_1] ml-0 mt-0 relative size-[20px]" data-name="user">
      <VuesaxLinearUser />
    </div>
  );
}

function Group1() {
  return (
    <div className="grid-cols-[max-content] grid-rows-[max-content] inline-grid leading-[0] place-items-start relative shrink-0">
      <User />
    </div>
  );
}

function NavigationMenuHome1() {
  return (
    <div className="absolute bg-[#bd4e2e] box-border content-stretch flex flex-col gap-[6px] items-center justify-center left-[333px] p-[18px] rounded-[71px] size-[65px] top-[6px]" data-name="navigation/menu - home">
      <Group1 />
    </div>
  );
}

function Bnb() {
  return (
    <div className="absolute bg-[#d6775c] h-[77px] left-1/2 rounded-[75px] top-0 translate-x-[-50%] w-[409px]" data-name="BNB-44">
      <Group4 />
      <NavigationMenuHome1 />
    </div>
  );
}

export default function Group() {
  return (
    <div className="relative size-full">
      <Bnb />
    </div>
  );
}