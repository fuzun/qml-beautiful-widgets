#include "Interface.h"

#include <QDir>

Interface::Interface(QObject *parent) : QObject(parent)
{

}

QStringList Interface::getDirFileList(const QString &_dir) const
{
    QDir dir(_dir);
    QStringList list = dir.entryList();
    std::transform(list.cbegin(), list.cend(), list.begin(), [dir](const QString& name) -> QString { return dir.path() + QString("/") + name;});
    return list;
}
