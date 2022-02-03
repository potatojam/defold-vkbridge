import '@vkontakte/vkui';
import { AppRoot, ConfigProvider, AdaptivityProvider, PromoBanner } from '@vkontakte/vkui';
import React from 'react';
import ReactDOM from 'react-dom';
import '@vkontakte/vkui/dist/vkui.css';

const promoBannerProps: any = {
    title: 'Заголовок',
    domain: 'vk.com',
    trackingLink: 'https://vk.com',
    ctaText: 'Перейти',
    advertisingLabel: 'Реклама',
    iconLink:
        'https://sun9-7.userapi.com/c846420/v846420985/1526c3/ISX7VF8NjZk.jpg',
    description: 'Описание рекламы',
    ageRestrictions: '14+',
    statistics: [
        { url: '', type: 'playbackStarted' },
        { url: '', type: 'click' }
    ]
};

const App: any = () => {
    return React.createElement(
        AppRoot,
        {
            mode: 'partial'
        },
        React.createElement(PromoBanner, {
            bannerData: promoBannerProps
        } as any)
    );
};

ReactDOM.render(
    React.createElement(
        ConfigProvider,
        null,
        React.createElement(
            AdaptivityProvider,
            null,
            React.createElement(App, null)
        )
    ),
    document.getElementById('vk-container')
);
