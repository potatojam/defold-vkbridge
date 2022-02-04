/* eslint-disable camelcase */
// import { AppRoot, ConfigProvider, AdaptivityProvider, PromoBanner, FixedLayout, View } from '@vkontakte/vkui';
// Partial imports reduse script size.
import AppRoot from '@vkontakte/vkui/dist/components/AppRoot/AppRoot';
import ConfigProvider from '@vkontakte/vkui/dist/components/ConfigProvider/ConfigProvider';
import AdaptivityProvider from '@vkontakte/vkui/dist/components/AdaptivityProvider/AdaptivityProvider';
import PromoBanner from '@vkontakte/vkui/dist/components/PromoBanner/PromoBanner';
import FixedLayout from '@vkontakte/vkui/dist/components/FixedLayout/FixedLayout';
import View from '@vkontakte/vkui/dist/components/View/View';
import React from 'react';
import ReactDOM from 'react-dom';
// import '@vkontakte/vkui/dist/vkui.css';
// Partial imports reduse script size.
import '@vkontakte/vkui/dist/cssm/components/AppRoot/AppRoot.css';
import '@vkontakte/vkui/dist/cssm/components/PromoBanner/PromoBanner.css';
import '@vkontakte/vkui/dist/cssm/components/FixedLayout/FixedLayout.css';
import '@vkontakte/vkui/dist/cssm/components/View/View.css';
import '@vkontakte/vkui/dist/cssm/components/SimpleCell/SimpleCell.css';
import '@vkontakte/vkui/dist/cssm/components/FocusVisible/FocusVisible.css';
import '@vkontakte/vkui/dist/cssm/components/Avatar/Avatar.css';
import '@vkontakte/vkui/dist/cssm/components/Tappable/Tappable.css';
import '@vkontakte/vkui/dist/cssm/components/Typography/Caption/Caption.css';
import '@vkontakte/vkui/dist/cssm/components/Button/Button.css';
import '@vkontakte/vkui/dist/cssm/styles/themes.css';

declare type BannerData = {
    title?: string;
    url_types?: string;
    bannerID?: string;
    imageWidth?: number;
    imageHeight?: number;
    imageLink?: string;
    trackingLink?: string;
    type?: string;
    iconWidth?: number;
    domain?: string;
    ctaText?: string;
    advertisingLabel?: string;
    iconLink?: string;
    statistics?: Array<{
        type: 'playbackStarted' | 'click';
        url: string;
    }>;
    openInBrowser?: boolean;
    iconHeight?: number;
    directLink?: boolean;
    navigationType?: string;
    description?: string;
    ageRestrictions?: string;
    /** @deprecated */
    ageRestriction?: number;
};

declare type WebViewBannerProps = {
    bannerConfigs: BannerData[];
};

class WebViewBanner extends React.Component {

    public props: WebViewBannerProps;

    public constructor(props: WebViewBannerProps) {
        super(props);
    }

    public renderPromoBanner(promoBannerProps: BannerData): JSX.Element {
        return (
            <PromoBanner
                bannerData={promoBannerProps}
                onClose={() => console.log('onClose')}
                isCloseButtonHidden={true}
            />
        );
    }

    public renderPromoBanners(bannerConfigs: BannerData[]): JSX.Element[] {
        return bannerConfigs.map((promoBannerProps: BannerData) =>
            this.renderPromoBanner(promoBannerProps)
        );
    }

    public render(): JSX.Element {
        return (
            <div>
                {this.renderPromoBanners(this.props.bannerConfigs)}
            </div>
        );
    }
};

export = class App {

    public showBanner(bannerConfigs: BannerData[], position: 'top' | 'bottom', scheme: 'light' | 'dark'): void {
        ReactDOM.render(
            <ConfigProvider appearance={scheme}>
                <AdaptivityProvider>
                    <AppRoot mode='partial'>
                        <View activePanel='promo'>
                            {/* <Panel id='promo'> */}
                            <FixedLayout id='promo' vertical={position}>
                                <WebViewBanner bannerConfigs={bannerConfigs} />
                            </FixedLayout>
                            {/* </Panel> */}
                        </View>
                    </AppRoot>
                </AdaptivityProvider>
            </ConfigProvider>,
            document.getElementById('vk-container')
        );
    }

    public hideBanner(): void {
        ReactDOM.render(
            <ConfigProvider>
            </ConfigProvider>,
            document.getElementById('vk-container')
        );
    }

};
