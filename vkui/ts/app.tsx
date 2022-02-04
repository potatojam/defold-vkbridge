/* eslint-disable camelcase */
// import { AppRoot, ConfigProvider, AdaptivityProvider, PromoBanner, FixedLayout, View } from '@vkontakte/vkui';
import AppRoot from '@vkontakte/vkui/dist/components/AppRoot/AppRoot';
import ConfigProvider from '@vkontakte/vkui/dist/components/ConfigProvider/ConfigProvider';
import AdaptivityProvider from '@vkontakte/vkui/dist/components/AdaptivityProvider/AdaptivityProvider';
import PromoBanner from '@vkontakte/vkui/dist/components/PromoBanner/PromoBanner';
import FixedLayout from '@vkontakte/vkui/dist/components/FixedLayout/FixedLayout';
import View from '@vkontakte/vkui/dist/components/View/View';
// import Panel from '@vkontakte/vkui/dist/components/Panel/Panel';
import React from 'react';
import ReactDOM from 'react-dom';
import '@vkontakte/vkui/dist/vkui.css';

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

    public showBanner(bannerConfigs: BannerData[], position: 'top' | 'bottom'): void {
        ReactDOM.render(
            <ConfigProvider>
                <AdaptivityProvider>
                    <AppRoot mode='partial'>
                        <View activePanel='promo'>
                            {/* <Panel id='promo'> */}
                            <FixedLayout id="promo" vertical={position}>
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
